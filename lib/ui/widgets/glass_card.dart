import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../../theme/app_theme.dart';

/// A frosted-glass surface: translucent fill, hairline highlight border,
/// continuous rounded corners, and (optionally) a backdrop blur of whatever
/// sits behind it.
///
/// Set [blur] to false for surfaces nested inside another [GlassCard] —
/// stacked backdrop blurs are expensive and visually muddy.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.padding = EdgeInsets.zero,
    this.blur = true,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool blur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = GlassPalette.of(context);
    final shape = BorderRadius.circular(radius);

    Widget surface = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.fill,
        borderRadius: shape,
        border: Border.all(color: palette.border),
      ),
      child: child,
    );

    if (blur) {
      surface = ClipRSuperellipse(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: surface,
        ),
      );
      // The drop shadow must sit outside the clip or it gets cut off.
      surface = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: surface,
      );
    }

    if (onTap == null) return surface;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: surface),
    );
  }
}
