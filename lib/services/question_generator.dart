import 'dart:math';

import '../models/chord.dart';
import '../models/level.dart';
import '../models/note.dart';
import '../models/quiz.dart';

/// A chord multiple-choice question.
class ChordQuestion extends QuizQuestion {
  ChordQuestion({required this.chord, required this.chordOptions});

  final Chord chord;
  final List<ChordQuality> chordOptions;

  @override
  List<int> get notesToPlay =>
      chord.voicedWithin(kKeyboardLowMidi, kKeyboardHighMidi);

  @override
  bool get playTogether => true;

  @override
  List<int> get notesToHighlight => notesToPlay;

  @override
  List<Labeled> get options => chordOptions;

  @override
  Labeled get answer => chord.quality;

  @override
  String get revealLabel => chord.quality.isSeventh || chord.inversion > 0
      ? chord.nameWithInversion
      : chord.name;
}

/// Generates randomized chord questions for a [Level].
class ChordQuestionGenerator implements QuizGenerator {
  ChordQuestionGenerator(this.level, {Random? random})
      : _random = random ?? Random();

  final Level level;
  final Random _random;

  @override
  ChordQuestion next() {
    final quality = level.qualities[_random.nextInt(level.qualities.length)];

    final root = level.lowestRootMidi +
        _random.nextInt(level.highestRootMidi - level.lowestRootMidi + 1);

    final maxInv = min(level.maxInversion, quality.size - 1);
    final inversion = maxInv == 0 ? 0 : _random.nextInt(maxInv + 1);

    final chord = Chord(rootMidi: root, quality: quality, inversion: inversion);

    return ChordQuestion(
      chord: chord,
      chordOptions: _buildOptions(quality),
    );
  }

  /// Builds [Level.optionCount] unique options that always include the correct
  /// answer, drawn from the level's quality pool and shuffled.
  List<ChordQuality> _buildOptions(ChordQuality answer) {
    final pool = level.qualities.toList()..remove(answer);
    pool.shuffle(_random);

    final wanted = min(level.optionCount, level.qualities.length);
    final options = <ChordQuality>[answer, ...pool.take(wanted - 1)];
    options.shuffle(_random);
    return options;
  }
}
