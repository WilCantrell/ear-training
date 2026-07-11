import 'dart:math';

import '../models/interval.dart';
import '../models/interval_level.dart';
import '../models/note.dart';
import '../models/quiz.dart';

/// An interval multiple-choice question.
class IntervalQuestion extends QuizQuestion {
  IntervalQuestion({required this.interval, required this.intervalOptions});

  final MusicalInterval interval;
  final List<IntervalQuality> intervalOptions;

  @override
  List<int> get notesToPlay =>
      interval.voicedWithin(kKeyboardLowMidi, kKeyboardHighMidi);

  @override
  bool get playTogether => interval.playTogether;

  @override
  List<int> get notesToHighlight => notesToPlay;

  @override
  List<Labeled> get options => intervalOptions;

  @override
  Labeled get answer => interval.quality;

  @override
  String get revealLabel => interval.revealLabel;
}

/// Generates randomized interval questions for an [IntervalLevel].
class IntervalQuestionGenerator implements QuizGenerator {
  IntervalQuestionGenerator(this.level, {Random? random})
      : _random = random ?? Random();

  final IntervalLevel level;
  final Random _random;

  @override
  IntervalQuestion next() {
    final quality = level.qualities[_random.nextInt(level.qualities.length)];
    final direction =
        level.directions[_random.nextInt(level.directions.length)];
    final low = level.lowestLowMidi +
        _random.nextInt(level.highestLowMidi - level.lowestLowMidi + 1);

    final interval = MusicalInterval(
      lowMidi: low,
      quality: quality,
      direction: direction,
    );

    return IntervalQuestion(
      interval: interval,
      intervalOptions: _buildOptions(quality),
    );
  }

  List<IntervalQuality> _buildOptions(IntervalQuality answer) {
    final pool = level.qualities.toList()..remove(answer);
    pool.shuffle(_random);

    final wanted = min(level.optionCount, level.qualities.length);
    final options = <IntervalQuality>[answer, ...pool.take(wanted - 1)];
    options.shuffle(_random);
    return options;
  }
}
