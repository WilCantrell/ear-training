import 'dart:math';

import '../models/note.dart';
import '../models/pitch.dart';
import '../models/quiz.dart';

/// A pitch-discrimination question: two pure tones play and the user says
/// whether the second was higher, lower or the same. Always rendered as sine
/// waves so the cent-level detune is exact.
class PitchQuestion extends QuizQuestion {
  PitchQuestion({
    required this.baseMidi,
    required this.cents,
    required this.direction,
  });

  final int baseMidi;
  final int cents;
  final PitchAnswer direction;

  @override
  List<int> get notesToPlay => const [];

  @override
  bool get playTogether => false;

  @override
  bool get pureTones => true;

  @override
  List<AudioEvent> get events {
    final detune = switch (direction) {
      PitchAnswer.higher => cents / 100.0,
      PitchAnswer.lower => -cents / 100.0,
      PitchAnswer.same => 0.0,
    };
    return [
      AudioEvent([baseMidi.toDouble()], seconds: 0.9, gapAfter: 0.4),
      AudioEvent([baseMidi + detune], seconds: 0.9),
    ];
  }

  @override
  List<int> get notesToHighlight => const [];

  @override
  List<Labeled> get options => PitchAnswer.values;

  @override
  Labeled get answer => direction;

  @override
  String get revealLabel => switch (direction) {
    PitchAnswer.higher => '$cents¢ sharper than ${Note.name(baseMidi)}',
    PitchAnswer.lower => '$cents¢ flatter than ${Note.name(baseMidi)}',
    PitchAnswer.same => 'Same pitch (${Note.name(baseMidi)})',
  };
}

/// Generates randomized pitch-discrimination questions for a [PitchLevel].
class PitchQuestionGenerator implements QuizGenerator {
  PitchQuestionGenerator(this.level, {Random? random})
    : _random = random ?? Random();

  final PitchLevel level;
  final Random _random;

  @override
  PitchQuestion next() {
    // G3..G5 — comfortably audible sine range.
    final base = 55 + _random.nextInt(25);
    final direction =
        PitchAnswer.values[_random.nextInt(PitchAnswer.values.length)];

    return PitchQuestion(
      baseMidi: base,
      cents: level.cents,
      direction: direction,
    );
  }
}
