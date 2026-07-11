import 'dart:math';

import '../models/comparison.dart';
import '../models/interval.dart';
import '../models/note.dart';
import '../models/quiz.dart';

/// An interval-comparison question: two intervals play and the user says
/// which is wider (or that they match).
class ComparisonQuestion extends QuizQuestion {
  ComparisonQuestion({
    required this.firstLow,
    required this.firstSemitones,
    required this.secondLow,
    required this.secondSemitones,
    required this.harmonic,
    required this.answerOptions,
  });

  final int firstLow;
  final int firstSemitones;
  final int secondLow;
  final int secondSemitones;
  final bool harmonic;
  final List<ComparisonAnswer> answerOptions;

  @override
  List<int> get notesToPlay => const [];

  @override
  bool get playTogether => false;

  @override
  List<AudioEvent> get events {
    final a1 = firstLow.toDouble();
    final a2 = (firstLow + firstSemitones).toDouble();
    final b1 = secondLow.toDouble();
    final b2 = (secondLow + secondSemitones).toDouble();
    if (harmonic) {
      return [
        AudioEvent([a1, a2], seconds: 0.9, gapAfter: 0.5),
        AudioEvent([b1, b2], seconds: 0.9),
      ];
    }
    return [
      AudioEvent([a1], seconds: 0.5, gapAfter: 0.04),
      AudioEvent([a2], seconds: 0.5, gapAfter: 0.5),
      AudioEvent([b1], seconds: 0.5, gapAfter: 0.04),
      AudioEvent([b2], seconds: 0.5),
    ];
  }

  @override
  List<int> get notesToHighlight => const [];

  @override
  List<Labeled> get options => answerOptions;

  @override
  Labeled get answer {
    if (firstSemitones == secondSemitones) return ComparisonAnswer.same;
    return firstSemitones > secondSemitones
        ? ComparisonAnswer.first
        : ComparisonAnswer.second;
  }

  @override
  String get revealLabel {
    // IntervalQuality.values is ordered by semitones 1..12.
    final q1 = IntervalQuality.values[firstSemitones - 1];
    final q2 = IntervalQuality.values[secondSemitones - 1];
    if (firstSemitones == secondSemitones) return '${q1.label} both times';
    return '${q1.symbol} then ${q2.symbol}';
  }
}

/// Generates randomized interval-comparison questions for a
/// [ComparisonLevel].
class ComparisonQuestionGenerator implements QuizGenerator {
  ComparisonQuestionGenerator(this.level, {Random? random})
    : _random = random ?? Random();

  final ComparisonLevel level;
  final Random _random;

  @override
  ComparisonQuestion next() {
    final first = 1 + _random.nextInt(12);
    int second;
    if (level.allowSame && _random.nextInt(3) == 0) {
      second = first;
    } else {
      final candidates = [
        for (var s = 1; s <= 12; s++)
          if ((s - first).abs() >= level.minDifference) s,
      ];
      second = candidates[_random.nextInt(candidates.length)];
    }

    int lowFor(int semitones) {
      final maxLow = kKeyboardHighMidi - semitones;
      final span = maxLow - kKeyboardLowMidi + 1;
      return kKeyboardLowMidi + _random.nextInt(span);
    }

    return ComparisonQuestion(
      firstLow: lowFor(first),
      firstSemitones: first,
      secondLow: lowFor(second),
      secondSemitones: second,
      harmonic: level.harmonic,
      answerOptions: level.answerOptions,
    );
  }
}
