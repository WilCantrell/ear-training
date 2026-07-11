import 'dart:math';

import '../models/note.dart';
import '../models/quiz.dart';
import '../models/scale.dart';
import '../models/scale_level.dart';

/// A scale multiple-choice question.
class ScaleQuestion extends QuizQuestion {
  ScaleQuestion({required this.scale, required this.scaleOptions});

  final MusicalScale scale;
  final List<ScaleQuality> scaleOptions;

  @override
  List<int> get notesToPlay =>
      scale.voicedWithin(kKeyboardLowMidi, kKeyboardHighMidi);

  @override
  bool get playTogether => false; // scales are played melodically

  @override
  List<int> get notesToHighlight => notesToPlay;

  @override
  List<Labeled> get options => scaleOptions;

  @override
  Labeled get answer => scale.quality;

  @override
  String get revealLabel => scale.revealLabel;
}

/// Generates randomized scale questions for a [ScaleLevel].
class ScaleQuestionGenerator implements QuizGenerator {
  ScaleQuestionGenerator(this.level, {Random? random})
      : _random = random ?? Random();

  final ScaleLevel level;
  final Random _random;

  @override
  ScaleQuestion next() {
    final quality = level.qualities[_random.nextInt(level.qualities.length)];
    final root = level.lowestRootMidi +
        _random.nextInt(level.highestRootMidi - level.lowestRootMidi + 1);

    return ScaleQuestion(
      scale: MusicalScale(rootMidi: root, quality: quality),
      scaleOptions: _buildOptions(quality),
    );
  }

  List<ScaleQuality> _buildOptions(ScaleQuality answer) {
    final pool = level.qualities.toList()..remove(answer);
    pool.shuffle(_random);

    final wanted = min(level.optionCount, level.qualities.length);
    final options = <ScaleQuality>[answer, ...pool.take(wanted - 1)];
    options.shuffle(_random);
    return options;
  }
}
