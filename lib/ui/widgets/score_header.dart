import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Progress + score strip shown above the answer choices.
class ScoreHeader extends StatelessWidget {
  const ScoreHeader({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.score,
    required this.streak,
  });

  final int questionNumber;
  final int totalQuestions;
  final int score;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final gray = MacosColors.systemGrayColor.resolveFrom(context);
    final progress = (questionNumber - 1) / totalQuestions * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Question $questionNumber of $totalQuestions',
              style: theme.typography.body.copyWith(color: gray),
            ),
            const Spacer(),
            if (streak >= 2) ...[
              Text('🔥 $streak', style: theme.typography.body),
              const SizedBox(width: 12),
            ],
            Text('Score: $score', style: theme.typography.body),
          ],
        ),
        const SizedBox(height: 8),
        ProgressBar(value: progress.clamp(0, 100).toDouble()),
      ],
    );
  }
}
