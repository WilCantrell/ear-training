import 'quiz.dart';
import 'scale.dart';

/// A difficulty level for the Scales module. Difficulty rises through the set
/// of scales considered, from the familiar major/minor forms out to modes and
/// symmetric scales.
class ScaleLevel implements QuizLevel {
  const ScaleLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.qualities,
    required this.optionCount,
    this.lowestRootMidi = 48, // C3
    this.highestRootMidi = 60, // C4
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;

  /// Scale types that can appear, and the distractor pool.
  final List<ScaleQuality> qualities;

  final int optionCount;
  final int lowestRootMidi;
  final int highestRootMidi;
}

const List<ScaleLevel> kScaleLevels = [
  ScaleLevel(
    id: 1,
    name: 'Major vs Minor',
    description: 'Tell a major scale from a natural minor scale.',
    qualities: [ScaleQuality.major, ScaleQuality.naturalMinor],
    optionCount: 2,
  ),
  ScaleLevel(
    id: 2,
    name: 'Minor Forms',
    description: 'Major and the three minor scales (natural, harmonic, melodic).',
    qualities: [
      ScaleQuality.major,
      ScaleQuality.naturalMinor,
      ScaleQuality.harmonicMinor,
      ScaleQuality.melodicMinor,
    ],
    optionCount: 4,
  ),
  ScaleLevel(
    id: 3,
    name: 'Church Modes',
    description: 'The seven diatonic modes, from Ionian to Locrian.',
    qualities: [
      ScaleQuality.major, // Ionian
      ScaleQuality.dorian,
      ScaleQuality.phrygian,
      ScaleQuality.lydian,
      ScaleQuality.mixolydian,
      ScaleQuality.naturalMinor, // Aeolian
      ScaleQuality.locrian,
    ],
    optionCount: 4,
  ),
  ScaleLevel(
    id: 4,
    name: 'Pentatonic & Symmetric',
    description: 'Major/minor pentatonic, blues and whole-tone scales.',
    qualities: [
      ScaleQuality.majorPentatonic,
      ScaleQuality.minorPentatonic,
      ScaleQuality.blues,
      ScaleQuality.wholeTone,
    ],
    optionCount: 4,
  ),
  ScaleLevel(
    id: 5,
    name: 'All Scales',
    description: 'Every scale type in the trainer.',
    qualities: ScaleQuality.values,
    optionCount: 4,
  ),
];
