import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// App-wide macOS themes. We lean on macos_ui defaults (which track the system
/// appearance) and only set the accent color.
class AppTheme {
  const AppTheme._();

  static MacosThemeData get light =>
      MacosThemeData.light().copyWith(primaryColor: MacosColors.systemBlueColor);

  static MacosThemeData get dark =>
      MacosThemeData.dark().copyWith(primaryColor: MacosColors.systemBlueColor);

  /// Display style for page-level titles ("Choose a level", "Session
  /// complete"). FrancoisOne ships only a regular weight, so pin w400 to
  /// avoid Flutter synthesizing a faux bold.
  static TextStyle pageTitle(BuildContext context) =>
      MacosTheme.of(context).typography.largeTitle.copyWith(
        fontFamily: 'FrancoisOne',
        fontWeight: FontWeight.w400,
      );
}

/// Translucency constants for the Tahoe-style glass surfaces, per appearance.
class GlassPalette {
  const GlassPalette._({
    required this.fill,
    required this.border,
    required this.controlFill,
    required this.scrim,
    required this.sidebarFrost,
  });

  /// Body of a frosted card.
  final Color fill;

  /// Hairline highlight around a glass surface.
  final Color border;

  /// Flat translucent fill for controls nested inside a glass card.
  final Color controlFill;

  /// Full-window wash over the photo so text stays legible.
  final Color scrim;

  /// Tint under the blurred sidebar strip.
  final Color sidebarFrost;

  static const light = GlassPalette._(
    fill: Color(0x8CFFFFFF),
    border: Color(0x80FFFFFF),
    controlFill: Color(0x4DFFFFFF),
    scrim: Color(0x33FFFFFF),
    sidebarFrost: Color(0x4DFFFFFF),
  );

  static const dark = GlassPalette._(
    fill: Color(0x59000000),
    border: Color(0x1FFFFFFF),
    controlFill: Color(0x1AFFFFFF),
    scrim: Color(0x8C000000),
    sidebarFrost: Color(0x4D000000),
  );

  static GlassPalette of(BuildContext context) =>
      MacosTheme.of(context).brightness == Brightness.dark ? dark : light;
}
