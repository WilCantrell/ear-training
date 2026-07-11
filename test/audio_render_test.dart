import 'dart:io';

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:eartraining/models/chord.dart';
import 'package:eartraining/models/sound_type.dart';
import 'package:flutter_test/flutter_test.dart';

/// Exercises the synthesis path end-to-end (load SoundFont -> note on -> render)
/// without the native SoLoud layer, and asserts the chord produces real audio.
void main() {
  Synthesizer loadSynth() {
    final sf2 = File('assets/soundfonts/TimGM6mb.sf2');
    expect(sf2.existsSync(), isTrue, reason: 'soundfont asset must exist');
    return Synthesizer.loadByteData(
      ByteData.sublistView(sf2.readAsBytesSync()),
      SynthesizerSettings(sampleRate: 44100),
    );
  }

  test('rendering a C major chord yields non-silent samples', () {
    final synth = loadSynth();
    // Select piano the way the engine does: by GM patch lookup, not index.
    final presets = synth.soundFont.presets;
    final pianoIndex = presets.indexWhere(
      (p) => p.bankNumber == 0 && p.patchNumber == 0,
    );
    expect(pianoIndex, greaterThanOrEqualTo(0));
    synth.selectPreset(channel: 0, preset: pianoIndex);

    for (final note in const Chord(rootMidi: 60, quality: ChordQuality.major).midiNotes) {
      synth.noteOn(channel: 0, key: note, velocity: 96);
    }

    const frames = 44100; // 1 second
    final left = Float32List(frames);
    final right = Float32List(frames);
    synth.render(left, right);

    final peak = left.fold<double>(0, (m, s) => s.abs() > m ? s.abs() : m);
    expect(peak, greaterThan(0.01), reason: 'chord should produce audible signal');
  });

  test('soundfont provides every soundfont-backed SoundType program', () {
    final presets = loadSynth().soundFont.presets;
    for (final type in SoundType.values.where((t) => t.usesSoundFont)) {
      expect(
        presets.any(
          (p) => p.bankNumber == 0 && p.patchNumber == type.gmProgram,
        ),
        isTrue,
        reason: 'missing GM program ${type.gmProgram} for ${type.name}',
      );
    }
  });
}
