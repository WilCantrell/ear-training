import 'package:flutter/widgets.dart';

import '../../theme/app_theme.dart';

/// Full-window photo backdrop: the image plus a legibility scrim. Everything
/// layered above (window, scaffolds) must keep a transparent background for it
/// to show through. The sidebar region is punched through to the native
/// NSVisualEffectView (see MainFlutterWindow.swift), so it frosts natively.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = GlassPalette.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/background.png', fit: BoxFit.cover),
        ColoredBox(color: palette.scrim),
        child,
      ],
    );
  }
}
