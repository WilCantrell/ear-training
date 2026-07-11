import 'quiz.dart';

/// A diatonic scale degree of the major scale, with its solfège name.
enum ScaleDegree implements Labeled {
  doh('Do (1)', 0),
  re('Re (2)', 2),
  mi('Mi (3)', 4),
  fa('Fa (4)', 5),
  sol('Sol (5)', 7),
  la('La (6)', 9),
  ti('Ti (7)', 11);

  const ScaleDegree(this.label, this.semitonesAboveTonic);

  @override
  final String label;

  /// Offset from the tonic within one octave of the major scale.
  final int semitonesAboveTonic;
}

/// A difficulty level for the scale-degree recognition module.
class DegreeLevel implements QuizLevel {
  const DegreeLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.degrees,
    this.anyOctave = false,
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;

  /// Degrees that can be asked (and the option pool).
  final List<ScaleDegree> degrees;

  /// When true the target note may land an octave above or below its home
  /// position, so the ear can't rely on register.
  final bool anyOctave;
}

const List<DegreeLevel> kDegreeLevels = [
  DegreeLevel(
    id: 1,
    name: 'Tonic Triad',
    description: 'A cadence sets the key, then one note: Do, Mi or Sol.',
    degrees: [ScaleDegree.doh, ScaleDegree.mi, ScaleDegree.sol],
  ),
  DegreeLevel(
    id: 2,
    name: 'Lower Five',
    description: 'Do through Sol — the lower half of the scale.',
    degrees: [
      ScaleDegree.doh,
      ScaleDegree.re,
      ScaleDegree.mi,
      ScaleDegree.fa,
      ScaleDegree.sol,
    ],
  ),
  DegreeLevel(
    id: 3,
    name: 'All Seven',
    description: 'Every diatonic degree of the major scale.',
    degrees: ScaleDegree.values,
  ),
  DegreeLevel(
    id: 4,
    name: 'Any Octave',
    description: 'Every degree, and the note may land in any octave.',
    degrees: ScaleDegree.values,
    anyOctave: true,
  ),
];
