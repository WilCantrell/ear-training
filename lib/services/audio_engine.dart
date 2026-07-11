import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz.dart' show AudioEvent;
import '../models/sound_type.dart';
import 'sine_renderer.dart';

/// Renders chords with a SoundFont synthesizer and plays them through SoLoud.
///
/// The synthesizer produces raw PCM, which we wrap in an in-memory WAV file
/// and hand to SoLoud via [SoLoud.loadMem]. This supports any chord, root and
/// inversion without bundling per-note samples.
class AudioEngine {
  AudioEngine._();
  static final AudioEngine instance = AudioEngine._();

  static const int _sampleRate = 44100;
  static const String _soundFontAsset = 'assets/soundfonts/TimGM6mb.sf2';
  static const String _soundTypePrefsKey = 'sound_type';

  Synthesizer? _synth;
  AudioSource? _currentSource;
  bool _initialized = false;
  SoundType _soundType = SoundType.piano;

  /// SoLoud caches loaded sounds by filename, so each chord must use a unique
  /// path or repeat plays would return the first (stale) buffer.
  int _loadCounter = 0;

  bool get isReady => _initialized && _synth != null;

  SoundType get soundType => _soundType;

  /// Initializes SoLoud and loads the SoundFont. Safe to call more than once.
  Future<void> init() async {
    if (_initialized) return;

    await SoLoud.instance.init(sampleRate: _sampleRate, channels: Channels.stereo);

    final bytes = await rootBundle.load(_soundFontAsset);
    final synth = Synthesizer.loadByteData(
      bytes,
      SynthesizerSettings(
        sampleRate: _sampleRate,
        blockSize: 64,
        maximumPolyphony: 64,
        enableReverbAndChorus: true,
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    _soundType = SoundType.fromName(prefs.getString(_soundTypePrefsKey));
    _applyPreset(synth);
    _synth = synth;

    _initialized = true;
  }

  /// Selects the soundfont preset for the current sound type. Must be called
  /// again after every synth.reset() — reset() reverts each channel's patch
  /// to 0.
  void _applyPreset(Synthesizer synth) {
    final program = _soundType.gmProgram;
    if (program == null) return; // sine bypasses the synth entirely
    final presets = synth.soundFont.presets;
    var index = presets.indexWhere(
      (p) => p.bankNumber == 0 && p.patchNumber == program,
    );
    if (index < 0) {
      index = presets.indexWhere((p) => p.patchNumber == program);
    }
    if (index < 0) index = 0; // soundfont lacks the patch → first preset
    synth.selectPreset(channel: 0, preset: index);
  }

  /// Sets the timbre and persists it. Callers re-render any cached WAVs so
  /// replays pick up the new sound.
  Future<void> setSoundType(SoundType type) async {
    if (type == _soundType) return;
    _soundType = type;
    final synth = _synth;
    if (synth != null) _applyPreset(synth);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundTypePrefsKey, type.name);
  }

  /// Renders [midiNotes] as a single chord and plays it. Replaces any chord
  /// currently sounding.
  Future<void> playChord(
    List<int> midiNotes, {
    int velocity = 96,
    double sustainSeconds = 2.2,
    double releaseSeconds = 0.9,
  }) async {
    final wav = renderChordToWav(
      midiNotes,
      velocity: velocity,
      sustainSeconds: sustainSeconds,
      releaseSeconds: releaseSeconds,
    );

    await _replaceAndPlay(wav);
  }

  /// Plays a previously rendered chord (e.g. the "Replay" button).
  Future<void> playRendered(Uint8List wavBytes) => _replaceAndPlay(wavBytes);

  /// Renders a chord to WAV bytes without playing — used so callers can cache
  /// the audio for instant replay.
  Uint8List renderChordToWav(
    List<int> midiNotes, {
    int velocity = 96,
    double sustainSeconds = 2.2,
    double releaseSeconds = 0.9,
  }) {
    if (_soundType == SoundType.sine) {
      final buf = SineRenderer.chord(
        midiNotes,
        sampleRate: _sampleRate,
        sustainSeconds: sustainSeconds,
        releaseSeconds: releaseSeconds,
      );
      return _interleavedFloatToWav(buf.left, buf.right);
    }
    final synth = _synth;
    if (synth == null) return Uint8List(0);
    return _renderChordToWav(
      synth,
      midiNotes,
      velocity: velocity,
      sustainSeconds: sustainSeconds,
      releaseSeconds: releaseSeconds,
    );
  }

  /// Renders a timed [AudioEvent] sequence (cadences, chord progressions,
  /// detuned tones) into a single WAV. When [pureTones] is set the events are
  /// rendered as sine waves regardless of the selected sound, so fractional
  /// pitches are reproduced exactly.
  Uint8List renderEventsToWav(
    List<AudioEvent> events, {
    bool pureTones = false,
    int velocity = 96,
    double releaseSeconds = 0.9,
  }) {
    if (events.isEmpty) return Uint8List(0);
    if (pureTones || _soundType == SoundType.sine) {
      final buf = SineRenderer.events(
        events,
        sampleRate: _sampleRate,
        releaseSeconds: releaseSeconds,
      );
      return _interleavedFloatToWav(buf.left, buf.right);
    }
    final synth = _synth;
    if (synth == null) return Uint8List(0);

    synth.reset();
    _applyPreset(synth);

    var totalFrames = (releaseSeconds * _sampleRate).round();
    for (final event in events) {
      totalFrames += ((event.seconds + event.gapAfter) * _sampleRate).round();
    }
    final left = Float32List(totalFrames);
    final right = Float32List(totalFrames);

    var offset = 0;
    for (final event in events) {
      final eventFrames = (event.seconds * _sampleRate).round();
      final gapFrames =
          ((event.seconds + event.gapAfter) * _sampleRate).round() -
          eventFrames;
      for (final note in event.notes) {
        synth.noteOn(channel: 0, key: note.round(), velocity: velocity);
      }
      _renderInto(synth, left, right, offset, eventFrames);
      offset += eventFrames;
      synth.noteOffAll(immediate: false);
      _renderInto(synth, left, right, offset, gapFrames);
      offset += gapFrames;
    }
    // Final decay tail.
    _renderInto(synth, left, right, offset, totalFrames - offset);

    return _interleavedFloatToWav(left, right);
  }

  /// Renders [midiNotes] one after another (a melodic line) into a single WAV,
  /// e.g. for ascending/descending intervals.
  Uint8List renderSequenceToWav(
    List<int> midiNotes, {
    int velocity = 96,
    double noteSeconds = 0.95,
    double gapSeconds = 0.12,
    double releaseSeconds = 0.7,
  }) {
    if (midiNotes.isEmpty) return Uint8List(0);
    if (_soundType == SoundType.sine) {
      final buf = SineRenderer.sequence(
        midiNotes,
        sampleRate: _sampleRate,
        noteSeconds: noteSeconds,
        gapSeconds: gapSeconds,
        releaseSeconds: releaseSeconds,
      );
      return _interleavedFloatToWav(buf.left, buf.right);
    }
    final synth = _synth;
    if (synth == null) return Uint8List(0);

    synth.reset();
    _applyPreset(synth);
    final noteFrames = (noteSeconds * _sampleRate).round();
    final gapFrames = (gapSeconds * _sampleRate).round();
    final tailFrames = (releaseSeconds * _sampleRate).round();
    final perNote = noteFrames + gapFrames;
    final totalFrames = perNote * midiNotes.length + tailFrames;

    final left = Float32List(totalFrames);
    final right = Float32List(totalFrames);

    var offset = 0;
    for (final note in midiNotes) {
      synth.noteOn(channel: 0, key: note, velocity: velocity);
      _renderInto(synth, left, right, offset, noteFrames);
      offset += noteFrames;
      synth.noteOffAll(immediate: false);
      _renderInto(synth, left, right, offset, gapFrames);
      offset += gapFrames;
    }
    // Final decay tail.
    _renderInto(synth, left, right, offset, tailFrames);

    return _interleavedFloatToWav(left, right);
  }

  /// Renders [frames] of audio into [left]/[right] starting at [offset].
  void _renderInto(
    Synthesizer synth,
    Float32List left,
    Float32List right,
    int offset,
    int frames,
  ) {
    if (frames <= 0) return;
    synth.render(
      Float32List.sublistView(left, offset, offset + frames),
      Float32List.sublistView(right, offset, offset + frames),
    );
  }

  Future<void> _replaceAndPlay(Uint8List wavBytes) async {
    if (wavBytes.isEmpty) return;

    // Dispose the previously playing chord first. Each load uses a unique
    // filename so its hash never collides with the new one we're about to
    // load — otherwise disposing here could free the live source.
    final previous = _currentSource;
    _currentSource = null;
    if (previous != null) {
      await SoLoud.instance.disposeSource(previous);
    }

    final source =
        await SoLoud.instance.loadMem('chord_${_loadCounter++}.wav', wavBytes);
    _currentSource = source;
    await SoLoud.instance.play(source);
  }

  Uint8List _renderChordToWav(
    Synthesizer synth,
    List<int> midiNotes, {
    required int velocity,
    required double sustainSeconds,
    required double releaseSeconds,
  }) {
    synth.reset();
    _applyPreset(synth);
    for (final note in midiNotes) {
      synth.noteOn(channel: 0, key: note, velocity: velocity);
    }

    final sustainFrames = (sustainSeconds * _sampleRate).round();
    final releaseFrames = (releaseSeconds * _sampleRate).round();
    final totalFrames = sustainFrames + releaseFrames;

    final left = Float32List(totalFrames);
    final right = Float32List(totalFrames);

    // Sustain portion.
    final sustainLeft = Float32List.sublistView(left, 0, sustainFrames);
    final sustainRight = Float32List.sublistView(right, 0, sustainFrames);
    synth.render(sustainLeft, sustainRight);

    // Release the keys and render the decay tail.
    synth.noteOffAll(immediate: false);
    final releaseLeft = Float32List.sublistView(left, sustainFrames);
    final releaseRight = Float32List.sublistView(right, sustainFrames);
    synth.render(releaseLeft, releaseRight);

    return _interleavedFloatToWav(left, right);
  }

  /// Interleaves two mono float channels and wraps them in a 16-bit PCM WAV.
  Uint8List _interleavedFloatToWav(Float32List left, Float32List right) {
    final frames = left.length;
    const channels = 2;
    const bitsPerSample = 16;
    final byteRate = _sampleRate * channels * bitsPerSample ~/ 8;
    const blockAlign = channels * bitsPerSample ~/ 8;
    final dataBytes = frames * blockAlign;

    final buffer = ByteData(44 + dataBytes);
    var offset = 0;

    void writeString(String s) {
      for (final code in s.codeUnits) {
        buffer.setUint8(offset++, code);
      }
    }

    writeString('RIFF');
    buffer.setUint32(offset, 36 + dataBytes, Endian.little);
    offset += 4;
    writeString('WAVE');
    writeString('fmt ');
    buffer.setUint32(offset, 16, Endian.little); // fmt chunk size
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // PCM
    offset += 2;
    buffer.setUint16(offset, channels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, _sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;
    writeString('data');
    buffer.setUint32(offset, dataBytes, Endian.little);
    offset += 4;

    for (var i = 0; i < frames; i++) {
      buffer.setInt16(offset, _floatToPcm16(left[i]), Endian.little);
      offset += 2;
      buffer.setInt16(offset, _floatToPcm16(right[i]), Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  int _floatToPcm16(double sample) {
    final clamped = sample.clamp(-1.0, 1.0);
    return (clamped * 32767).round();
  }

  Future<void> dispose() async {
    final source = _currentSource;
    if (source != null) {
      await SoLoud.instance.disposeSource(source);
      _currentSource = null;
    }
    SoLoud.instance.deinit();
    _initialized = false;
    _synth = null;
  }
}
