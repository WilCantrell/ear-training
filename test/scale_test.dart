import 'dart:math';

import 'package:eartraining/models/scale.dart';
import 'package:eartraining/models/scale_level.dart';
import 'package:eartraining/services/scale_question_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicalScale', () {
    test('major scale has the expected notes from C4', () {
      const c = MusicalScale(rootMidi: 60, quality: ScaleQuality.major);
      expect(c.notes, [60, 62, 64, 65, 67, 69, 71, 72]);
    });

    test('every scale ends an octave above its root', () {
      for (final q in ScaleQuality.values) {
        final s = MusicalScale(rootMidi: 60, quality: q);
        expect(s.notes.first, 60);
        expect(s.notes.last, 72);
        // Ascending and strictly increasing.
        for (var i = 1; i < s.notes.length; i++) {
          expect(s.notes[i], greaterThan(s.notes[i - 1]));
        }
      }
    });

    test('voicing keeps every note inside the keyboard window', () {
      for (var root = 48; root <= 60; root++) {
        for (final q in ScaleQuality.values) {
          final voiced =
              MusicalScale(rootMidi: root, quality: q).voicedWithin(48, 72);
          expect(voiced.first, greaterThanOrEqualTo(48));
          expect(voiced.last, lessThanOrEqualTo(72));
        }
      }
    });
  });

  group('ScaleQuestionGenerator', () {
    test('every level produces valid questions', () {
      for (final level in kScaleLevels) {
        final generator = ScaleQuestionGenerator(level, random: Random(11));
        for (var i = 0; i < 150; i++) {
          final q = generator.next();
          expect(q.options, contains(q.answer));
          expect(q.options.toSet().length, q.options.length);
          expect(q.options.length, level.optionCount);
          for (final opt in q.options) {
            expect(level.qualities, contains(opt));
          }
          expect(q.playTogether, isFalse);
          expect(q.notesToPlay.length, greaterThanOrEqualTo(6));
        }
      }
    });
  });
}
