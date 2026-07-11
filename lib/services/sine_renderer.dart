import 'dart:math' as math;
import 'dart:typed_data';

import '../models/quiz.dart' show AudioEvent;

/// Renders sine-wave notes with a click-free envelope into stereo float
/// buffers, mirroring the soundfont render timings so WAV durations match.
///
/// Pure Dart — no SoLoud or soundfont dependency — so it runs in plain unit
/// tests. AudioEngine wraps the returned buffers in a WAV exactly like the
/// synthesizer output.
class SineRenderer {
  const SineRenderer._();

  static const double _attackSeconds = 0.012;

  /// Per-note amplitude: a 4-note chord peaks at 0.88, leaving headroom.
  static const double _gainPerNote = 0.22;

  /// All notes sound together, then fade out over [releaseSeconds].
  static ({Float32List left, Float32List right}) chord(
    List<int> midiNotes, {
    required int sampleRate,
    double sustainSeconds = 2.2,
    double releaseSeconds = 0.9,
  }) {
    final sustainFrames = (sustainSeconds * sampleRate).round();
    final releaseFrames = (releaseSeconds * sampleRate).round();
    final left = Float32List(sustainFrames + releaseFrames);
    final right = Float32List(sustainFrames + releaseFrames);
    for (final note in midiNotes) {
      _addNote(
        left,
        right,
        midiNote: note.toDouble(),
        sampleRate: sampleRate,
        startFrame: 0,
        sustainFrames: sustainFrames,
        releaseFrames: releaseFrames,
      );
    }
    return (left: left, right: right);
  }

  /// Renders a timed [AudioEvent] sequence (notes, chords, or fractional
  /// pitches) followed by a final tail of [releaseSeconds].
  static ({Float32List left, Float32List right}) events(
    List<AudioEvent> events, {
    required int sampleRate,
    double releaseSeconds = 0.9,
  }) {
    var totalFrames = (releaseSeconds * sampleRate).round();
    for (final event in events) {
      totalFrames += ((event.seconds + event.gapAfter) * sampleRate).round();
    }
    final left = Float32List(totalFrames);
    final right = Float32List(totalFrames);
    var start = 0;
    for (final event in events) {
      final eventFrames = (event.seconds * sampleRate).round();
      final maxRelease = totalFrames - (start + eventFrames);
      final release = math.min((0.18 * sampleRate).round(), maxRelease);
      for (final note in event.notes) {
        _addNote(
          left,
          right,
          midiNote: note,
          sampleRate: sampleRate,
          startFrame: start,
          sustainFrames: eventFrames,
          releaseFrames: release,
        );
      }
      start += ((event.seconds + event.gapAfter) * sampleRate).round();
    }
    return (left: left, right: right);
  }

  /// Notes play one after another (a melodic line), like the synthesizer's
  /// sequence rendering: note + gap per entry, then a final tail.
  static ({Float32List left, Float32List right}) sequence(
    List<int> midiNotes, {
    required int sampleRate,
    double noteSeconds = 0.95,
    double gapSeconds = 0.12,
    double releaseSeconds = 0.7,
  }) {
    final noteFrames = (noteSeconds * sampleRate).round();
    final gapFrames = (gapSeconds * sampleRate).round();
    final tailFrames = (releaseSeconds * sampleRate).round();
    final perNote = noteFrames + gapFrames;
    final totalFrames = perNote * midiNotes.length + tailFrames;
    final left = Float32List(totalFrames);
    final right = Float32List(totalFrames);
    for (var i = 0; i < midiNotes.length; i++) {
      final start = i * perNote;
      // The release may overlap the next note's onset; buffers are summed.
      final maxRelease = totalFrames - (start + noteFrames);
      final release = math.min((0.18 * sampleRate).round(), maxRelease);
      _addNote(
        left,
        right,
        midiNote: midiNotes[i].toDouble(),
        sampleRate: sampleRate,
        startFrame: start,
        sustainFrames: noteFrames,
        releaseFrames: release,
      );
    }
    return (left: left, right: right);
  }

  static void _addNote(
    Float32List left,
    Float32List right, {
    required double midiNote,
    required int sampleRate,
    required int startFrame,
    required int sustainFrames,
    required int releaseFrames,
  }) {
    final freq = 440.0 * math.pow(2.0, (midiNote - 69) / 12.0);
    final omega = 2 * math.pi * freq / sampleRate;
    final attackFrames = math.max(1, (_attackSeconds * sampleRate).round());
    final totalFrames = sustainFrames + releaseFrames;
    for (var i = 0; i < totalFrames; i++) {
      var env = 1.0;
      if (i < attackFrames) env = i / attackFrames;
      if (i >= sustainFrames && releaseFrames > 0) {
        // Raised-cosine fade reaching exactly 0, so the WAV never clicks.
        final t = (i - sustainFrames) / releaseFrames;
        env *= 0.5 * (1 + math.cos(math.pi * t));
      }
      final sample = math.sin(omega * i) * _gainPerNote * env;
      left[startFrame + i] += sample;
      right[startFrame + i] += sample;
    }
  }
}
