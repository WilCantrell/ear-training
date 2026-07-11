/// Timbres the user can choose for playback. All but [sine] map to a General
/// MIDI program in the bundled soundfont (bank 0); sine is synthesized in
/// Dart by SineRenderer.
enum SoundType {
  piano('Piano', 0), // Acoustic Grand Piano
  voice('Voice', 52), // Choir Aahs — sustained, vocal
  sine('Sine', null), // pure tone, not soundfont-backed
  strings('Strings', 48), // String Ensemble 1
  organ('Organ', 19); // Church Organ — steady sustain, clear partials

  const SoundType(this.label, this.gmProgram);

  final String label;
  final int? gmProgram;

  bool get usesSoundFont => gmProgram != null;

  static SoundType fromName(String? name) => SoundType.values.firstWhere(
    (type) => type.name == name,
    orElse: () => SoundType.piano,
  );
}
