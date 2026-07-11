import 'quiz.dart';

/// The answer choices for an interval-comparison question.
enum ComparisonAnswer implements Labeled {
  first('First is wider'),
  second('Second is wider'),
  same('Same size');

  const ComparisonAnswer(this.label);

  @override
  final String label;
}

/// A difficulty level for the interval-comparison module. Difficulty rises as
/// the size difference between the two intervals shrinks, then the intervals
/// turn harmonic.
class ComparisonLevel implements QuizLevel {
  const ComparisonLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.minDifference,
    required this.allowSame,
    this.harmonic = false,
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;

  /// Smallest semitone difference between the two intervals (when they
  /// differ).
  final int minDifference;

  /// Whether "same size" questions can appear (and the option is offered).
  final bool allowSame;

  /// Play each interval's notes together instead of melodically.
  final bool harmonic;

  List<ComparisonAnswer> get answerOptions => allowSame
      ? ComparisonAnswer.values
      : const [ComparisonAnswer.first, ComparisonAnswer.second];
}

const List<ComparisonLevel> kComparisonLevels = [
  ComparisonLevel(
    id: 1,
    name: 'Clear Difference',
    description: 'Two melodic intervals at least 3 semitones apart.',
    minDifference: 3,
    allowSame: false,
  ),
  ComparisonLevel(
    id: 2,
    name: 'Closer Sizes',
    description: 'At least 2 semitones apart — or exactly the same.',
    minDifference: 2,
    allowSame: true,
  ),
  ComparisonLevel(
    id: 3,
    name: 'One Semitone',
    description: 'A single semitone apart, or the same size.',
    minDifference: 1,
    allowSame: true,
  ),
  ComparisonLevel(
    id: 4,
    name: 'Harmonic',
    description: 'Both intervals sound as dyads. Any difference, or same.',
    minDifference: 1,
    allowSame: true,
    harmonic: true,
  ),
];
