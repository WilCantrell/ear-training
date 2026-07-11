import 'note.dart';
import 'quiz.dart';

/// A scale type, expressed as semitone offsets from the root. Each list ends on
/// the octave (12) so the scale resolves when played.
enum ScaleQuality implements Labeled {
  major('Major', [0, 2, 4, 5, 7, 9, 11, 12]),
  naturalMinor('Natural Minor', [0, 2, 3, 5, 7, 8, 10, 12]),
  harmonicMinor('Harmonic Minor', [0, 2, 3, 5, 7, 8, 11, 12]),
  melodicMinor('Melodic Minor', [0, 2, 3, 5, 7, 9, 11, 12]),
  dorian('Dorian', [0, 2, 3, 5, 7, 9, 10, 12]),
  phrygian('Phrygian', [0, 1, 3, 5, 7, 8, 10, 12]),
  lydian('Lydian', [0, 2, 4, 6, 7, 9, 11, 12]),
  mixolydian('Mixolydian', [0, 2, 4, 5, 7, 9, 10, 12]),
  locrian('Locrian', [0, 1, 3, 5, 6, 8, 10, 12]),
  majorPentatonic('Major Pentatonic', [0, 2, 4, 7, 9, 12]),
  minorPentatonic('Minor Pentatonic', [0, 3, 5, 7, 10, 12]),
  blues('Blues', [0, 3, 5, 6, 7, 10, 12]),
  wholeTone('Whole Tone', [0, 2, 4, 6, 8, 10, 12]);

  const ScaleQuality(this.label, this.intervals);

  @override
  final String label;

  final List<int> intervals;
}

/// A concrete scale played from [rootMidi], ascending.
class MusicalScale {
  const MusicalScale({required this.rootMidi, required this.quality});

  final int rootMidi;
  final ScaleQuality quality;

  /// The scale's notes, ascending from the root to the octave.
  List<int> get notes => [for (final i in quality.intervals) rootMidi + i];

  /// The notes shifted by whole octaves so they fit within [low]..[high].
  List<int> voicedWithin(int low, int high) {
    var shift = 0;
    while (notes.last + shift > high) {
      shift -= 12;
    }
    while (notes.first + shift < low) {
      shift += 12;
    }
    return [for (final n in notes) n + shift];
  }

  /// e.g. "C Dorian", "A Major".
  String get revealLabel => '${Note.pitchClassName(rootMidi)} ${quality.label}';
}
