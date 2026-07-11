import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../models/note.dart';

/// A piano spanning a fixed MIDI window ([lowMidi]..[highMidi]) so it stays put
/// on screen. The keys in [highlighted] are filled with the accent color;
/// pass an empty list to show the keyboard with nothing lit.
class PianoKeyboard extends StatelessWidget {
  const PianoKeyboard({
    super.key,
    required this.highlighted,
    this.lowMidi = kKeyboardLowMidi,
    this.highMidi = kKeyboardHighMidi,
    this.height = 92,
  });

  final List<int> highlighted;
  final int lowMidi;
  final int highMidi;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _KeyboardPainter(
          highlighted: highlighted.toSet(),
          lowMidi: lowMidi,
          highMidi: highMidi,
          accent: theme.primaryColor,
        ),
      ),
    );
  }
}

class _KeyboardPainter extends CustomPainter {
  _KeyboardPainter({
    required this.highlighted,
    required this.lowMidi,
    required this.highMidi,
    required this.accent,
  });

  final Set<int> highlighted;
  final int lowMidi;
  final int highMidi;
  final Color accent;

  /// Pitch classes that are black keys.
  static const Set<int> _black = {1, 3, 6, 8, 10};

  /// White-key pitch classes that have a black key immediately above them.
  static const Set<int> _hasBlackAbove = {0, 2, 5, 7, 9};

  @override
  void paint(Canvas canvas, Size size) {
    final endC = highMidi;

    final whiteNotes = <int>[
      for (var n = lowMidi; n <= highMidi; n++)
        if (!_black.contains(n % 12)) n,
    ];

    final whiteW = size.width / whiteNotes.length;
    const whiteRadius = Radius.circular(4);
    const blackRadius = Radius.circular(3);

    final whiteFill = Paint()..color = const Color(0xFFFAFAFA);
    final whiteHi = Paint()..color = accent;
    final blackFill = Paint()..color = const Color(0xFF1C1C1E);
    // A darker shade of the accent so lit black keys read distinctly against
    // lit white keys.
    final blackHi = Paint()..color = _darken(accent, 0.22);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFB0B0B5);

    // White keys.
    for (var i = 0; i < whiteNotes.length; i++) {
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(i * whiteW, 0, whiteW, size.height),
        bottomLeft: whiteRadius,
        bottomRight: whiteRadius,
      );
      canvas.drawRRect(rect, highlighted.contains(whiteNotes[i]) ? whiteHi : whiteFill);
      canvas.drawRRect(rect, stroke);
      _maybeLabelC(canvas, whiteNotes[i], i * whiteW, whiteW, size.height);
    }

    // Black keys, drawn straddling the gap after each eligible white key.
    final blackW = whiteW * 0.6;
    final blackH = size.height * 0.62;
    for (var i = 0; i < whiteNotes.length; i++) {
      final note = whiteNotes[i];
      if (!_hasBlackAbove.contains(note % 12)) continue;
      final blackNote = note + 1;
      if (blackNote > endC) continue;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH((i + 1) * whiteW - blackW / 2, 0, blackW, blackH),
        bottomLeft: blackRadius,
        bottomRight: blackRadius,
      );
      canvas.drawRRect(rect, highlighted.contains(blackNote) ? blackHi : blackFill);
    }
  }

  /// Faint octave marker (e.g. "C4") under each C, for orientation.
  void _maybeLabelC(Canvas canvas, int note, double x, double w, double h) {
    if (note % 12 != 0) return;
    final tp = TextPainter(
      text: TextSpan(
        text: Note.name(note),
        style: const TextStyle(fontSize: 9, color: Color(0xFF8E8E93)),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w);
    tp.paint(canvas, Offset(x + (w - tp.width) / 2, h - tp.height - 3));
  }

  @override
  bool shouldRepaint(covariant _KeyboardPainter old) =>
      !setEquals(old.highlighted, highlighted) || old.accent != accent;
}

/// Returns [color] with its lightness reduced by [amount] (0–1).
Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
