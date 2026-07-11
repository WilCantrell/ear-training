import 'dart:math';

import 'package:eartraining/models/level.dart';
import 'package:eartraining/services/question_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChordQuestionGenerator', () {
    test('every level produces valid questions over many draws', () {
      for (final level in kChordLevels) {
        final generator = ChordQuestionGenerator(level, random: Random(42));
        for (var i = 0; i < 200; i++) {
          final q = generator.next();

          // Correct answer is always present in the options.
          expect(q.options, contains(q.answer));

          // Options are unique.
          expect(q.options.toSet().length, q.options.length);

          // Option count matches the level (capped by pool size).
          final expectedCount = level.optionCount > level.qualities.length
              ? level.qualities.length
              : level.optionCount;
          expect(q.options.length, expectedCount);

          // All options come from the level's pool.
          for (final opt in q.options) {
            expect(level.qualities, contains(opt));
          }

          // Inversion respects the level limit and chord size.
          expect(q.chord.inversion, lessThanOrEqualTo(level.maxInversion));
          expect(q.chord.inversion, lessThan(q.chord.quality.size));

          // Root stays inside the configured range.
          expect(q.chord.rootMidi, greaterThanOrEqualTo(level.lowestRootMidi));
          expect(q.chord.rootMidi, lessThanOrEqualTo(level.highestRootMidi));

          // The chord is voiced inside the keyboard window and plays together.
          expect(q.playTogether, isTrue);
          expect(q.notesToPlay.first, greaterThanOrEqualTo(48));
          expect(q.notesToPlay.last, lessThanOrEqualTo(72));
        }
      }
    });

    test('level 1 only ever asks major vs minor', () {
      final level = kChordLevels.first;
      final generator = ChordQuestionGenerator(level, random: Random(7));
      for (var i = 0; i < 50; i++) {
        final q = generator.next();
        expect(level.qualities, contains(q.answer));
        expect(q.chord.inversion, 0);
      }
    });
  });
}
