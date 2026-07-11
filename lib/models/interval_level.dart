import 'interval.dart';
import 'quiz.dart';

/// A difficulty level for the Intervals module. Difficulty rises through the
/// set of intervals, the playing direction, and finally harmonic presentation.
class IntervalLevel implements QuizLevel {
  const IntervalLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.qualities,
    required this.directions,
    required this.optionCount,
    this.lowestLowMidi = 48, // C3
    this.highestLowMidi = 57, // A3
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;

  /// Interval qualities that can appear, and the distractor pool.
  final List<IntervalQuality> qualities;

  /// Directions a question may use (one is chosen at random per question).
  final List<IntervalDirection> directions;

  final int optionCount;
  final int lowestLowMidi;
  final int highestLowMidi;
}

const List<IntervalLevel> kIntervalLevels = [
  IntervalLevel(
    id: 1,
    name: 'Perfect & Octave',
    description: 'Major 3rd, Perfect 5th and Octave, played ascending.',
    qualities: [
      IntervalQuality.major3,
      IntervalQuality.perfect5,
      IntervalQuality.octave,
    ],
    directions: [IntervalDirection.ascending],
    optionCount: 3,
  ),
  IntervalLevel(
    id: 2,
    name: 'Thirds & Sixths',
    description: 'Minor/major 3rds and 6ths, played ascending.',
    qualities: [
      IntervalQuality.minor3,
      IntervalQuality.major3,
      IntervalQuality.minor6,
      IntervalQuality.major6,
    ],
    directions: [IntervalDirection.ascending],
    optionCount: 4,
  ),
  IntervalLevel(
    id: 3,
    name: 'All Ascending',
    description: 'Every interval within an octave, played ascending.',
    qualities: IntervalQuality.values,
    directions: [IntervalDirection.ascending],
    optionCount: 4,
  ),
  IntervalLevel(
    id: 4,
    name: 'Both Directions',
    description: 'Every interval, played ascending or descending.',
    qualities: IntervalQuality.values,
    directions: [IntervalDirection.ascending, IntervalDirection.descending],
    optionCount: 4,
  ),
  IntervalLevel(
    id: 5,
    name: 'Harmonic',
    description: 'Every interval, both notes sounded together.',
    qualities: IntervalQuality.values,
    directions: [IntervalDirection.harmonic],
    optionCount: 4,
  ),
];
