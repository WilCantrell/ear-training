import 'note.dart';
import 'quiz.dart';

/// The quality (sonority) of a chord, independent of its root or inversion.
enum ChordQuality implements Labeled {
  major('Major', '', [0, 4, 7]),
  minor('Minor', 'm', [0, 3, 7]),
  diminished('Diminished', '°', [0, 3, 6]),
  augmented('Augmented', '+', [0, 4, 8]),
  dominant7('Dominant 7th', '7', [0, 4, 7, 10]),
  major7('Major 7th', 'maj7', [0, 4, 7, 11]),
  minor7('Minor 7th', 'm7', [0, 3, 7, 10]),
  halfDim7('Half-diminished 7th', 'ø7', [0, 3, 6, 10]);

  const ChordQuality(this.label, this.symbol, this.intervals);

  /// Full descriptive name shown to the user, e.g. "Minor 7th".
  @override
  final String label;

  /// Compact chord symbol suffix, e.g. "m7" (appended after the root name).
  final String symbol;

  /// Semitone offsets from the root, in root position.
  final List<int> intervals;

  /// Number of distinct notes (3 for triads, 4 for sevenths).
  int get size => intervals.length;

  /// True for four-note seventh chords.
  bool get isSeventh => size == 4;
}

/// A concrete chord: a [quality] built on a [rootMidi] note, optionally
/// inverted by raising the lowest [inversion] notes by an octave.
class Chord {
  const Chord({
    required this.rootMidi,
    required this.quality,
    this.inversion = 0,
  });

  final int rootMidi;
  final ChordQuality quality;

  /// 0 = root position, 1 = first inversion, etc. Must be < quality.size.
  final int inversion;

  /// The MIDI notes to sound, lowest first, with the inversion applied.
  List<int> get midiNotes {
    final base = quality.intervals.map((i) => rootMidi + i).toList();
    // Raise the lowest `inversion` notes by an octave, then re-sort so the
    // result is voiced bottom-to-top.
    for (var i = 0; i < inversion; i++) {
      base[i] += 12;
    }
    base.sort();
    return base;
  }

  /// The chord's notes shifted by whole octaves so they fit within
  /// [low]..[high] inclusive. Any close-position chord spans well under two
  /// octaves, so it always fits a two-octave window.
  List<int> voicedWithin(int low, int high) {
    var notes = midiNotes;
    while (notes.last > high) {
      notes = [for (final n in notes) n - 12];
    }
    while (notes.first < low) {
      notes = [for (final n in notes) n + 12];
    }
    return notes;
  }

  /// e.g. "Cmaj7", "Em", "G7".
  String get name => '${Note.pitchClassName(rootMidi)}${quality.symbol}';

  /// e.g. "Cmaj7 (1st inversion)".
  String get nameWithInversion {
    const ordinals = ['root position', '1st inversion', '2nd inversion', '3rd inversion'];
    final suffix = inversion < ordinals.length ? ordinals[inversion] : '${inversion}th inversion';
    return '$name ($suffix)';
  }
}
