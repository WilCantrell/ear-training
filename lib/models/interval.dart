import 'quiz.dart';

/// A musical interval quality, measured in semitones from the lower note.
enum IntervalQuality implements Labeled {
  minor2('Minor 2nd', 'm2', 1),
  major2('Major 2nd', 'M2', 2),
  minor3('Minor 3rd', 'm3', 3),
  major3('Major 3rd', 'M3', 4),
  perfect4('Perfect 4th', 'P4', 5),
  tritone('Tritone', 'TT', 6),
  perfect5('Perfect 5th', 'P5', 7),
  minor6('Minor 6th', 'm6', 8),
  major6('Major 6th', 'M6', 9),
  minor7('Minor 7th', 'm7', 10),
  major7('Major 7th', 'M7', 11),
  octave('Octave', 'P8', 12);

  const IntervalQuality(this.label, this.symbol, this.semitones);

  @override
  final String label;

  final String symbol;
  final int semitones;
}

/// How the two notes of an interval are presented.
enum IntervalDirection {
  ascending('ascending'),
  descending('descending'),
  harmonic('harmonic');

  const IntervalDirection(this.label);
  final String label;
}

/// A concrete interval: a [quality] played from [lowMidi], in some [direction].
class MusicalInterval {
  const MusicalInterval({
    required this.lowMidi,
    required this.quality,
    required this.direction,
  });

  /// The lower of the two pitches (the higher is [lowMidi] + semitones).
  final int lowMidi;
  final IntervalQuality quality;
  final IntervalDirection direction;

  int get highMidi => lowMidi + quality.semitones;

  /// The two pitches in the order they should sound. Harmonic uses low→high
  /// order (it plays together anyway); descending plays high then low.
  List<int> get playOrder => switch (direction) {
        IntervalDirection.ascending => [lowMidi, highMidi],
        IntervalDirection.descending => [highMidi, lowMidi],
        IntervalDirection.harmonic => [lowMidi, highMidi],
      };

  bool get playTogether => direction == IntervalDirection.harmonic;

  /// Both pitches, shifted by whole octaves so they fit within [low]..[high].
  /// The temporal order is preserved (both notes shift together).
  List<int> voicedWithin(int low, int high) {
    var shift = 0;
    while (highMidi + shift > high) {
      shift -= 12;
    }
    while (lowMidi + shift < low) {
      shift += 12;
    }
    return [for (final n in playOrder) n + shift];
  }

  /// e.g. "Perfect 5th (ascending)".
  String get revealLabel => '${quality.label} (${direction.label})';
}
