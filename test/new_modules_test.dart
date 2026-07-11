import 'dart:math';

import 'package:eartraining/models/comparison.dart';
import 'package:eartraining/models/degree.dart';
import 'package:eartraining/models/note.dart';
import 'package:eartraining/models/pitch.dart';
import 'package:eartraining/models/progression.dart';
import 'package:eartraining/models/quiz.dart';
import 'package:eartraining/services/comparison_question_generator.dart';
import 'package:eartraining/services/degree_question_generator.dart';
import 'package:eartraining/services/pitch_question_generator.dart';
import 'package:eartraining/services/progression_question_generator.dart';
import 'package:eartraining/services/sine_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DegreeQuestionGenerator', () {
    test('every level produces valid questions over many draws', () {
      for (final level in kDegreeLevels) {
        final gen = DegreeQuestionGenerator(level, random: Random(42));
        for (var i = 0; i < 200; i++) {
          final q = gen.next();
          expect(q.options, contains(q.answer));
          expect(q.options.toSet().length, q.options.length);
          expect(q.targetMidi, inInclusiveRange(kKeyboardLowMidi, kKeyboardHighMidi));
          expect(q.events, hasLength(5), reason: 'cadence (4) + target note');
          expect(q.events.last.notes, [q.targetMidi.toDouble()]);
          expect(q.notesToHighlight, [q.targetMidi]);
          // Target matches the degree within some octave of the tonic.
          final degree = q.answer as ScaleDegree;
          expect(
            (q.targetMidi - q.tonicMidi - degree.semitonesAboveTonic) % 12,
            0,
          );
          for (final event in q.events) {
            for (final note in event.notes) {
              expect(note, inInclusiveRange(48.0, 72.0));
            }
          }
        }
      }
    });
  });

  group('ComparisonQuestionGenerator', () {
    test('every level produces consistent questions over many draws', () {
      for (final level in kComparisonLevels) {
        final gen = ComparisonQuestionGenerator(level, random: Random(7));
        var sawSame = false;
        for (var i = 0; i < 300; i++) {
          final q = gen.next();
          expect(q.options, contains(q.answer));
          if (q.firstSemitones == q.secondSemitones) {
            sawSame = true;
            expect(level.allowSame, isTrue);
            expect(q.answer, ComparisonAnswer.same);
          } else {
            expect(
              (q.firstSemitones - q.secondSemitones).abs(),
              greaterThanOrEqualTo(level.minDifference),
            );
            expect(
              q.answer,
              q.firstSemitones > q.secondSemitones
                  ? ComparisonAnswer.first
                  : ComparisonAnswer.second,
            );
          }
          expect(q.events, hasLength(level.harmonic ? 2 : 4));
          for (final event in q.events) {
            for (final note in event.notes) {
              expect(note, inInclusiveRange(48.0, 72.0));
            }
          }
        }
        expect(sawSame, level.allowSame,
            reason: 'same-size questions appear iff the level allows them');
      }
    });
  });

  group('ProgressionQuestionGenerator', () {
    test('every level produces valid questions over many draws', () {
      for (final level in kProgressionLevels) {
        final gen = ProgressionQuestionGenerator(level, random: Random(3));
        for (var i = 0; i < 200; i++) {
          final q = gen.next();
          expect(q.options, contains(q.answer));
          expect(q.options.toSet().length, q.options.length);
          expect(q.options.length,
              min(level.optionCount, level.progressions.length));
          final progression = q.answer as ChordProgression;
          expect(q.events, hasLength(progression.steps.length));
          for (final event in q.events) {
            expect(event.notes, hasLength(3), reason: 'diatonic triads');
            for (final note in event.notes) {
              expect(note, inInclusiveRange(48.0, 72.0));
            }
          }
        }
      }
    });
  });

  group('PitchQuestionGenerator', () {
    test('detune matches the answer and questions are pure tones', () {
      for (final level in kPitchLevels) {
        final gen = PitchQuestionGenerator(level, random: Random(11));
        for (var i = 0; i < 200; i++) {
          final q = gen.next();
          expect(q.pureTones, isTrue);
          expect(q.events, hasLength(2));
          final base = q.events.first.notes.single;
          final second = q.events.last.notes.single;
          final expected = switch (q.answer as PitchAnswer) {
            PitchAnswer.higher => level.cents / 100.0,
            PitchAnswer.lower => -level.cents / 100.0,
            PitchAnswer.same => 0.0,
          };
          expect(second - base, closeTo(expected, 1e-9));
        }
      }
    });
  });

  group('SineRenderer.events', () {
    const sampleRate = 44100;

    test('total length covers all events plus the tail', () {
      const events = [
        AudioEvent([60], seconds: 0.5, gapAfter: 0.1),
        AudioEvent([64, 67], seconds: 0.7),
      ];
      final buf = SineRenderer.events(
        events,
        sampleRate: sampleRate,
        releaseSeconds: 0.4,
      );
      final expected = ((0.5 + 0.1) * sampleRate).round() +
          ((0.7 + 0.08) * sampleRate).round() +
          (0.4 * sampleRate).round();
      expect(buf.left.length, expected);

      var peak = 0.0;
      for (final s in buf.left) {
        if (s.abs() > peak) peak = s.abs();
      }
      expect(peak, greaterThan(0.1));
      expect(peak, lessThanOrEqualTo(1.0));
    });

    test('fractional pitches produce a different signal than integers', () {
      const a = [AudioEvent([69], seconds: 0.5)];
      const b = [AudioEvent([69.25], seconds: 0.5)];
      final bufA = SineRenderer.events(a, sampleRate: sampleRate);
      final bufB = SineRenderer.events(b, sampleRate: sampleRate);
      var maxDiff = 0.0;
      for (var i = 0; i < bufA.left.length; i++) {
        final d = (bufA.left[i] - bufB.left[i]).abs();
        if (d > maxDiff) maxDiff = d;
      }
      expect(maxDiff, greaterThan(0.05),
          reason: 'a 25-cent detune must audibly change the waveform');
    });
  });
}
