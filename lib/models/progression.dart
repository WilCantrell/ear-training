import 'chord.dart';
import 'quiz.dart';

/// A diatonic chord progression, as (semitones above tonic, quality) steps.
enum ChordProgression implements Labeled {
  oneFourFive('I – IV – V', [
    (0, ChordQuality.major),
    (5, ChordQuality.major),
    (7, ChordQuality.major),
  ]),
  oneFiveOne('I – V – I', [
    (0, ChordQuality.major),
    (7, ChordQuality.major),
    (0, ChordQuality.major),
  ]),
  oneFourOne('I – IV – I', [
    (0, ChordQuality.major),
    (5, ChordQuality.major),
    (0, ChordQuality.major),
  ]),
  twoFiveOne('ii – V – I', [
    (2, ChordQuality.minor),
    (7, ChordQuality.major),
    (0, ChordQuality.major),
  ]),
  oneSixFourFive('I – vi – IV – V', [
    (0, ChordQuality.major),
    (9, ChordQuality.minor),
    (5, ChordQuality.major),
    (7, ChordQuality.major),
  ]),
  oneFiveSixFour('I – V – vi – IV', [
    (0, ChordQuality.major),
    (7, ChordQuality.major),
    (9, ChordQuality.minor),
    (5, ChordQuality.major),
  ]),
  sixFourOneFive('vi – IV – I – V', [
    (9, ChordQuality.minor),
    (5, ChordQuality.major),
    (0, ChordQuality.major),
    (7, ChordQuality.major),
  ]),
  oneFourSixFive('I – IV – vi – V', [
    (0, ChordQuality.major),
    (5, ChordQuality.major),
    (9, ChordQuality.minor),
    (7, ChordQuality.major),
  ]);

  const ChordProgression(this.label, this.steps);

  @override
  final String label;

  final List<(int, ChordQuality)> steps;
}

/// A difficulty level for the chord-progression module.
class ProgressionLevel implements QuizLevel {
  const ProgressionLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.progressions,
    required this.optionCount,
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;

  final List<ChordProgression> progressions;
  final int optionCount;
}

const List<ProgressionLevel> kProgressionLevels = [
  ProgressionLevel(
    id: 1,
    name: 'Three-Chord Basics',
    description: 'I–IV–V, I–V–I and I–IV–I in random keys.',
    progressions: [
      ChordProgression.oneFourFive,
      ChordProgression.oneFiveOne,
      ChordProgression.oneFourOne,
    ],
    optionCount: 3,
  ),
  ProgressionLevel(
    id: 2,
    name: 'Adding Minor',
    description: 'The basics plus ii–V–I and I–vi–IV–V.',
    progressions: [
      ChordProgression.oneFourFive,
      ChordProgression.oneFiveOne,
      ChordProgression.twoFiveOne,
      ChordProgression.oneSixFourFive,
    ],
    optionCount: 4,
  ),
  ProgressionLevel(
    id: 3,
    name: 'Pop Progressions',
    description: 'Four-chord loops: I–V–vi–IV, I–vi–IV–V, vi–IV–I–V, I–IV–vi–V.',
    progressions: [
      ChordProgression.oneFiveSixFour,
      ChordProgression.oneSixFourFive,
      ChordProgression.sixFourOneFive,
      ChordProgression.oneFourSixFive,
    ],
    optionCount: 4,
  ),
  ProgressionLevel(
    id: 4,
    name: 'Everything',
    description: 'All eight progressions, three and four chords long.',
    progressions: ChordProgression.values,
    optionCount: 4,
  ),
];
