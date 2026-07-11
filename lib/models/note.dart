/// Inclusive MIDI window shown by the on-screen keyboard: two octaves, C3–C5.
/// Chords are voiced to fit inside this range so the keyboard never moves.
const int kKeyboardLowMidi = 48; // C3
const int kKeyboardHighMidi = 72; // C5

/// Pitch helpers built around MIDI note numbers.
///
/// MIDI note 60 is Middle C (C4). Each semitone is +1.
class Note {
  const Note._();

  static const List<String> _pitchClasses = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  /// MIDI number for [pitchClass] (0=C .. 11=B) in the given [octave]
  /// (scientific pitch notation, where C4 = 60).
  static int midi({required int pitchClass, required int octave}) {
    return (octave + 1) * 12 + pitchClass;
  }

  /// Human-readable name for a MIDI number, e.g. 60 -> "C4".
  static String name(int midi) {
    final pitchClass = midi % 12;
    final octave = (midi ~/ 12) - 1;
    return '${_pitchClasses[pitchClass]}$octave';
  }

  /// Just the pitch class name, e.g. 60 -> "C".
  static String pitchClassName(int midi) => _pitchClasses[midi % 12];
}
