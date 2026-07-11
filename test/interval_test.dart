import 'dart:math';

import 'package:eartraining/models/interval.dart';
import 'package:eartraining/models/interval_level.dart';
import 'package:eartraining/services/interval_question_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicalInterval', () {
    test('high note is low + semitones', () {
      const p5 = MusicalInterval(
        lowMidi: 60,
        quality: IntervalQuality.perfect5,
        direction: IntervalDirection.ascending,
      );
      expect(p5.highMidi, 67);
    });

    test('play order reflects direction', () {
      const asc = MusicalInterval(
        lowMidi: 60,
        quality: IntervalQuality.major3,
        direction: IntervalDirection.ascending,
      );
      const desc = MusicalInterval(
        lowMidi: 60,
        quality: IntervalQuality.major3,
        direction: IntervalDirection.descending,
      );
      expect(asc.playOrder, [60, 64]);
      expect(desc.playOrder, [64, 60]);
    });

    test('voicing fits the keyboard window and keeps the interval size', () {
      for (var low = 48; low <= 60; low++) {
        for (final q in IntervalQuality.values) {
          for (final dir in IntervalDirection.values) {
            final iv = MusicalInterval(lowMidi: low, quality: q, direction: dir);
            final voiced = iv.voicedWithin(48, 72);
            expect(voiced.reduce(min), greaterThanOrEqualTo(48));
            expect(voiced.reduce(max), lessThanOrEqualTo(72));
            // The gap between the two notes equals the interval size.
            expect((voiced[1] - voiced[0]).abs(), q.semitones);
          }
        }
      }
    });
  });

  group('IntervalQuestionGenerator', () {
    test('every level produces valid questions', () {
      for (final level in kIntervalLevels) {
        final generator = IntervalQuestionGenerator(level, random: Random(3));
        for (var i = 0; i < 200; i++) {
          final q = generator.next();
          expect(q.options, contains(q.answer));
          expect(q.options.toSet().length, q.options.length);
          expect(q.options.length, level.optionCount);
          for (final opt in q.options) {
            expect(level.qualities, contains(opt));
          }
          expect(level.directions, contains(q.interval.direction));
          expect(q.notesToPlay.length, 2);
        }
      }
    });

    test('harmonic level plays both notes together', () {
      final level = kIntervalLevels.last;
      final generator = IntervalQuestionGenerator(level, random: Random(9));
      for (var i = 0; i < 20; i++) {
        expect(generator.next().playTogether, isTrue);
      }
    });
  });
}
