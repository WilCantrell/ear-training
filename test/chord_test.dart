import 'package:eartraining/models/chord.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chord.midiNotes', () {
    test('root-position triads have the right intervals', () {
      // C4 = 60. C major = C E G.
      const cMajor = Chord(rootMidi: 60, quality: ChordQuality.major);
      expect(cMajor.midiNotes, [60, 64, 67]);

      const cMinor = Chord(rootMidi: 60, quality: ChordQuality.minor);
      expect(cMinor.midiNotes, [60, 63, 67]);
    });

    test('seventh chord has four notes', () {
      const dom7 = Chord(rootMidi: 60, quality: ChordQuality.dominant7);
      expect(dom7.midiNotes, [60, 64, 67, 70]);
    });

    test('first inversion raises the root an octave and re-voices low->high', () {
      // C major, 1st inversion = E G C(+octave) => 64, 67, 72.
      const cMajorInv1 =
          Chord(rootMidi: 60, quality: ChordQuality.major, inversion: 1);
      expect(cMajorInv1.midiNotes, [64, 67, 72]);
    });

    test('second inversion raises the two lowest notes', () {
      // C major, 2nd inversion = G C(+8) E(+8) => 67, 72, 76.
      const cMajorInv2 =
          Chord(rootMidi: 60, quality: ChordQuality.major, inversion: 2);
      expect(cMajorInv2.midiNotes, [67, 72, 76]);
    });

    test('all chords keep their pitch-class set under inversion', () {
      for (final quality in ChordQuality.values) {
        for (var inv = 0; inv < quality.size; inv++) {
          final chord = Chord(rootMidi: 60, quality: quality, inversion: inv);
          final classes = chord.midiNotes.map((n) => n % 12).toSet();
          final expected = quality.intervals.map((i) => (60 + i) % 12).toSet();
          expect(classes, expected, reason: '$quality inv $inv');
          expect(chord.midiNotes.length, quality.size);
          // Notes are sorted ascending.
          final sorted = [...chord.midiNotes]..sort();
          expect(chord.midiNotes, sorted);
        }
      }
    });
  });

  group('Chord.voicedWithin', () {
    test('fits every quality/inversion/root into the 2-octave keyboard window', () {
      const low = 48; // C3
      const high = 72; // C5
      for (var root = 48; root <= 60; root++) {
        for (final quality in ChordQuality.values) {
          for (var inv = 0; inv < quality.size; inv++) {
            final chord = Chord(rootMidi: root, quality: quality, inversion: inv);
            final voiced = chord.voicedWithin(low, high);
            expect(voiced.first, greaterThanOrEqualTo(low),
                reason: '$quality inv $inv root $root');
            expect(voiced.last, lessThanOrEqualTo(high),
                reason: '$quality inv $inv root $root');
            // Same set of pitch classes as the original chord.
            expect(
              voiced.map((n) => n % 12).toSet(),
              chord.midiNotes.map((n) => n % 12).toSet(),
            );
          }
        }
      }
    });
  });

  group('Chord naming', () {
    test('uses pitch class + symbol', () {
      expect(const Chord(rootMidi: 60, quality: ChordQuality.major).name, 'C');
      expect(const Chord(rootMidi: 62, quality: ChordQuality.minor7).name, 'Dm7');
    });
  });
}
