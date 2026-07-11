import 'dart:math';

import '../models/chord.dart';
import '../models/degree.dart';
import '../models/note.dart';
import '../models/quiz.dart';

/// A scale-degree question: a I–IV–V–I cadence establishes the key, then a
/// single note sounds and the user names its degree.
class DegreeQuestion extends QuizQuestion {
  DegreeQuestion({
    required this.tonicMidi,
    required this.degree,
    required this.targetMidi,
    required this.degreeOptions,
  });

  final int tonicMidi;
  final ScaleDegree degree;
  final int targetMidi;
  final List<ScaleDegree> degreeOptions;

  @override
  List<int> get notesToPlay => const [];

  @override
  bool get playTogether => false;

  @override
  List<AudioEvent> get events {
    List<double> chord(int rootOffset) => Chord(
      rootMidi: tonicMidi + rootOffset,
      quality: ChordQuality.major,
    ).voicedWithin(kKeyboardLowMidi, kKeyboardHighMidi).map((n) => n.toDouble()).toList();

    return [
      AudioEvent(chord(0), seconds: 0.5),
      AudioEvent(chord(5), seconds: 0.5),
      AudioEvent(chord(7), seconds: 0.5),
      AudioEvent(chord(0), seconds: 0.75, gapAfter: 0.45),
      AudioEvent([targetMidi.toDouble()], seconds: 1.1),
    ];
  }

  @override
  List<int> get notesToHighlight => [targetMidi];

  @override
  List<Labeled> get options => degreeOptions;

  @override
  Labeled get answer => degree;

  @override
  String get revealLabel =>
      '${degree.label} — ${Note.name(targetMidi)} in '
      '${Note.pitchClassName(tonicMidi)} major';
}

/// Generates randomized scale-degree questions for a [DegreeLevel].
class DegreeQuestionGenerator implements QuizGenerator {
  DegreeQuestionGenerator(this.level, {Random? random})
    : _random = random ?? Random();

  final DegreeLevel level;
  final Random _random;

  @override
  DegreeQuestion next() {
    // Tonic in C3..B3 keeps the cadence chords and target notes centered.
    final tonic = kKeyboardLowMidi + _random.nextInt(12);
    final degree = level.degrees[_random.nextInt(level.degrees.length)];

    var target = tonic + degree.semitonesAboveTonic;
    if (level.anyOctave) {
      final shift = (_random.nextInt(3) - 1) * 12; // -12, 0 or +12
      target += shift;
    }
    while (target > kKeyboardHighMidi) {
      target -= 12;
    }
    while (target < kKeyboardLowMidi) {
      target += 12;
    }

    final options = level.degrees.toList()..shuffle(_random);
    return DegreeQuestion(
      tonicMidi: tonic,
      degree: degree,
      targetMidi: target,
      degreeOptions: options,
    );
  }
}
