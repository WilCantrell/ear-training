// Shared abstractions that let different ear-training modules (chords,
// intervals, …) reuse the same session controller and UI.

/// Something that can be shown as a multiple-choice option.
abstract interface class Labeled {
  /// Full descriptive name, e.g. "Minor 7th" or "Perfect 5th".
  String get label;
}

/// A selectable difficulty level for a module.
abstract interface class QuizLevel {
  int get id;
  String get name;
  String get description;
}

/// One sonority in a timed audio sequence: a single note or a chord, held
/// for [seconds] and followed by [gapAfter] of silence.
class AudioEvent {
  const AudioEvent(this.notes, {this.seconds = 0.6, this.gapAfter = 0.08});

  /// MIDI pitches sounding together. Fractional values (e.g. 69.25 for
  /// A4 +25 cents) are honored by the pure-tone renderer and rounded to the
  /// nearest semitone by the soundfont.
  final List<double> notes;

  final double seconds;
  final double gapAfter;
}

/// One multiple-choice question, independent of what's being trained.
abstract class QuizQuestion {
  /// MIDI notes to sound, already voiced to fit the keyboard. For melodic
  /// questions this is in temporal (play) order. Ignored when [events] is
  /// provided.
  List<int> get notesToPlay;

  /// True if the notes sound simultaneously (a chord / harmonic interval);
  /// false if they should play one after another. Ignored when [events] is
  /// provided.
  bool get playTogether;

  /// Richer questions (cadences, chord progressions, detuned tones) describe
  /// their audio as a timed event sequence instead of [notesToPlay].
  List<AudioEvent>? get events => null;

  /// True to always render with pure sine tones regardless of the selected
  /// sound — needed when fractional pitches must be reproduced exactly.
  bool get pureTones => false;

  /// MIDI notes to light up on the keyboard once the answer is revealed.
  List<int> get notesToHighlight;

  List<Labeled> get options;
  Labeled get answer;

  /// What to show when revealing the answer, e.g. "Cmaj7 (1st inversion)".
  String get revealLabel;
}

/// Produces questions for a particular level.
abstract interface class QuizGenerator {
  QuizQuestion next();
}
