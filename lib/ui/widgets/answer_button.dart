import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../theme/app_theme.dart';

/// How an answer choice should be rendered given the session state.
enum AnswerState { idle, correct, wrong, dimmed }

/// A large multiple-choice button for a chord quality.
///
/// Flat translucent glass — no backdrop blur, since it always sits inside the
/// session page's already-blurred GlassCard.
class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    required this.state,
    required this.onPressed,
  });

  final String label;
  final AnswerState state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final palette = GlassPalette.of(context);

    Color background = palette.controlFill;
    Color border = palette.border;
    Color? foreground;
    IconData? icon;
    switch (state) {
      case AnswerState.idle:
      case AnswerState.dimmed:
        break;
      case AnswerState.correct:
        background = MacosColors.systemGreenColor.resolveFrom(context);
        border = MacosColors.transparent;
        foreground = MacosColors.white;
        icon = CupertinoIcons.checkmark_circle_fill;
      case AnswerState.wrong:
        background = MacosColors.systemRedColor.resolveFrom(context);
        border = MacosColors.transparent;
        foreground = MacosColors.white;
        icon = CupertinoIcons.xmark_circle_fill;
    }

    return Opacity(
      opacity: state == AnswerState.dimmed ? 0.45 : 1.0,
      child: MouseRegion(
        cursor: onPressed != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  MacosIcon(icon, color: foreground, size: 18),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.typography.headline.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
