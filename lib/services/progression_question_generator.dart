import 'dart:math';

import '../models/chord.dart';
import '../models/note.dart';
import '../models/progression.dart';
import '../models/quiz.dart';

/// A chord-progression question: a short diatonic progression plays and the
/// user names it by its roman numerals.
class ProgressionQuestion extends QuizQuestion {
  ProgressionQuestion({
    required this.tonicMidi,
    required this.progression,
    required this.progressionOptions,
  });

  final int tonicMidi;
  final ChordProgression progression;
  final List<ChordProgression> progressionOptions;

  @override
  List<int> get notesToPlay => const [];

  @override
  bool get playTogether => false;

  @override
  List<AudioEvent> get events {
    final steps = progression.steps;
    return [
      for (var i = 0; i < steps.length; i++)
        AudioEvent(
          Chord(rootMidi: tonicMidi + steps[i].$1, quality: steps[i].$2)
              .voicedWithin(kKeyboardLowMidi, kKeyboardHighMidi)
              .map((n) => n.toDouble())
              .toList(),
          seconds: i == steps.length - 1 ? 1.0 : 0.7,
          gapAfter: 0.09,
        ),
    ];
  }

  @override
  List<int> get notesToHighlight => const [];

  @override
  List<Labeled> get options => progressionOptions;

  @override
  Labeled get answer => progression;

  @override
  String get revealLabel =>
      '${progression.label} in ${Note.pitchClassName(tonicMidi)}';
}

/// Generates randomized progression questions for a [ProgressionLevel].
class ProgressionQuestionGenerator implements QuizGenerator {
  ProgressionQuestionGenerator(this.level, {Random? random})
    : _random = random ?? Random();

  final ProgressionLevel level;
  final Random _random;

  @override
  ProgressionQuestion next() {
    final progression =
        level.progressions[_random.nextInt(level.progressions.length)];
    final tonic = kKeyboardLowMidi + _random.nextInt(12);

    return ProgressionQuestion(
      tonicMidi: tonic,
      progression: progression,
      progressionOptions: _buildOptions(progression),
    );
  }

  List<ChordProgression> _buildOptions(ChordProgression answer) {
    final pool = level.progressions.toList()..remove(answer);
    pool.shuffle(_random);

    final wanted = min(level.optionCount, level.progressions.length);
    final options = <ChordProgression>[answer, ...pool.take(wanted - 1)];
    options.shuffle(_random);
    return options;
  }
}
