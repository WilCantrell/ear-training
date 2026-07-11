import 'package:eartraining/models/sound_type.dart';
import 'package:eartraining/services/sine_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleRate = 44100;

  group('SineRenderer.chord', () {
    test('renders a non-silent, click-free C major chord', () {
      final buf = SineRenderer.chord(
        const [60, 64, 67],
        sampleRate: sampleRate,
      );

      final expectedFrames =
          (2.2 * sampleRate).round() + (0.9 * sampleRate).round();
      expect(buf.left.length, expectedFrames);
      expect(buf.right.length, expectedFrames);

      var peak = 0.0;
      for (final s in buf.left) {
        if (s.abs() > peak) peak = s.abs();
      }
      expect(peak, greaterThan(0.1), reason: 'chord should be audible');
      expect(peak, lessThanOrEqualTo(1.0), reason: 'must not clip');

      expect(buf.left.first, 0, reason: 'attack starts from silence');
      expect(
        buf.left.last.abs(),
        lessThan(1e-3),
        reason: 'release must fade to zero (click-free)',
      );
    });
  });

  group('SineRenderer.sequence', () {
    test('renders each note into its window with the exact total length', () {
      const noteSeconds = 0.5;
      const gapSeconds = 0.1;
      const releaseSeconds = 0.3;
      final buf = SineRenderer.sequence(
        const [60, 64, 67],
        sampleRate: sampleRate,
        noteSeconds: noteSeconds,
        gapSeconds: gapSeconds,
        releaseSeconds: releaseSeconds,
      );

      final noteFrames = (noteSeconds * sampleRate).round();
      final gapFrames = (gapSeconds * sampleRate).round();
      final tailFrames = (releaseSeconds * sampleRate).round();
      expect(buf.left.length, 3 * (noteFrames + gapFrames) + tailFrames);

      for (var i = 0; i < 3; i++) {
        final start = i * (noteFrames + gapFrames);
        var peak = 0.0;
        for (var f = start; f < start + noteFrames; f++) {
          if (buf.left[f].abs() > peak) peak = buf.left[f].abs();
        }
        expect(peak, greaterThan(0.1), reason: 'note $i should be audible');
      }
    });
  });

  group('SoundType', () {
    test('fromName round-trips and falls back to piano', () {
      expect(SoundType.fromName('voice'), SoundType.voice);
      expect(SoundType.fromName('strings'), SoundType.strings);
      expect(SoundType.fromName(null), SoundType.piano);
      expect(SoundType.fromName('garbage'), SoundType.piano);
    });

    test('sine is the only type without a soundfont program', () {
      expect(SoundType.sine.usesSoundFont, isFalse);
      expect(
        SoundType.values.where((t) => !t.usesSoundFont),
        [SoundType.sine],
      );
    });
  });
}
