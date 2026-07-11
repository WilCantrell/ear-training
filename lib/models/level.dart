import 'chord.dart';
import 'quiz.dart';

/// A difficulty level for the Chords module. Difficulty rises through chord
/// complexity (triads -> sevenths) and the inversions that may be played.
class Level implements QuizLevel {
  const Level({
    required this.id,
    required this.name,
    required this.description,
    required this.qualities,
    required this.maxInversion,
    required this.optionCount,
    this.lowestRootMidi = 48, // C3
    this.highestRootMidi = 60, // C4
  });

  /// Stable id used for persisting best scores.
  @override
  final int id;
  @override
  final String name;
  @override
  final String description;

  /// Chord qualities that can appear at this level. Also the pool from which
  /// multiple-choice distractors are drawn.
  final List<ChordQuality> qualities;

  /// Highest inversion that may be played (0 = root position only).
  final int maxInversion;

  /// Number of multiple-choice options to present.
  final int optionCount;

  /// Inclusive MIDI range for randomly chosen chord roots.
  final int lowestRootMidi;
  final int highestRootMidi;
}

/// The five built-in levels, ordered by difficulty.
const List<Level> kChordLevels = [
  Level(
    id: 1,
    name: 'Major vs Minor',
    description: 'Identify major and minor triads in root position.',
    qualities: [ChordQuality.major, ChordQuality.minor],
    maxInversion: 0,
    optionCount: 2,
  ),
  Level(
    id: 2,
    name: 'All Triads',
    description: 'Major, minor, diminished and augmented triads, root position.',
    qualities: [
      ChordQuality.major,
      ChordQuality.minor,
      ChordQuality.diminished,
      ChordQuality.augmented,
    ],
    maxInversion: 0,
    optionCount: 4,
  ),
  Level(
    id: 3,
    name: 'Triad Inversions',
    description: 'All triads, now in root position or any inversion.',
    qualities: [
      ChordQuality.major,
      ChordQuality.minor,
      ChordQuality.diminished,
      ChordQuality.augmented,
    ],
    maxInversion: 2,
    optionCount: 4,
  ),
  Level(
    id: 4,
    name: 'Seventh Chords',
    description: 'Dominant, major, minor and half-diminished 7ths, root position.',
    qualities: [
      ChordQuality.dominant7,
      ChordQuality.major7,
      ChordQuality.minor7,
      ChordQuality.halfDim7,
    ],
    maxInversion: 0,
    optionCount: 4,
  ),
  Level(
    id: 5,
    name: 'Seventh Inversions',
    description: 'Seventh chords in root position or any of their inversions.',
    qualities: [
      ChordQuality.dominant7,
      ChordQuality.major7,
      ChordQuality.minor7,
      ChordQuality.halfDim7,
    ],
    maxInversion: 3,
    optionCount: 4,
  ),
];
