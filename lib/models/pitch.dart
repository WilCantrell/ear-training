import 'quiz.dart';

/// The answer choices for a pitch-discrimination question.
enum PitchAnswer implements Labeled {
  higher('Higher'),
  lower('Lower'),
  same('Same');

  const PitchAnswer(this.label);

  @override
  final String label;
}

/// A difficulty level for the pitch-discrimination module: how far the second
/// tone is detuned when it differs.
class PitchLevel implements QuizLevel {
  const PitchLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.cents,
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;

  /// Detune amount in cents (hundredths of a semitone).
  final int cents;
}

const List<PitchLevel> kPitchLevels = [
  PitchLevel(
    id: 1,
    name: 'Half Semitone',
    description: 'The second tone may differ by 50 cents.',
    cents: 50,
  ),
  PitchLevel(
    id: 2,
    name: 'Quarter Semitone',
    description: 'The difference shrinks to 25 cents.',
    cents: 25,
  ),
  PitchLevel(
    id: 3,
    name: 'Ten Cents',
    description: 'A 10-cent difference — near typical tuning tolerance.',
    cents: 10,
  ),
  PitchLevel(
    id: 4,
    name: 'Five Cents',
    description: 'A 5-cent difference — sharper than most ears.',
    cents: 5,
  ),
];
