import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../models/quiz.dart';
import '../../state/progress_store.dart';
import '../../theme/app_theme.dart';
import '../widgets/glass_card.dart';

/// Lists the difficulty levels for a module. Shared by chords, intervals, etc.
class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({
    super.key,
    required this.title,
    required this.intro,
    required this.levels,
    required this.scoreKeyPrefix,
    required this.questionsPerSession,
    required this.onSelect,
  });

  final String title;
  final String intro;
  final List<QuizLevel> levels;
  final String scoreKeyPrefix;
  final int questionsPerSession;
  final ValueChanged<QuizLevel> onSelect;

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  Map<int, LevelProgress> _progressByLevel = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await ProgressStore(
      widget.scoreKeyPrefix,
    ).loadAll(widget.levels);
    if (mounted) setState(() => _progressByLevel = progress);
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await showMacosAlertDialog<bool>(
      context: context,
      builder: (dialogContext) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.arrow_counterclockwise_circle),
        title: const Text('Reset progress?'),
        message: const Text(
          'This clears best scores, session counts, and accuracy for this module.',
          textAlign: TextAlign.center,
        ),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Reset'),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (confirmed != true) return;

    await ProgressStore(widget.scoreKeyPrefix).resetAll(widget.levels);
    if (mounted) {
      setState(() {
        _progressByLevel = {
          for (final level in widget.levels)
            level.id: const LevelProgress.empty(),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final hasProgress = _progressByLevel.values.any(
      (progress) => progress.hasPractice,
    );
    return MacosScaffold(
      backgroundColor: MacosColors.transparent,
      toolBar: ToolBar(
        title: Text(widget.title),
        enableBlur: true,
        decoration: BoxDecoration(
          color: theme.canvasColor.withValues(alpha: 0.5),
        ),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      _ProgressFooter.scrollInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a level',
                          style: AppTheme.pageTitle(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.intro,
                          style: theme.typography.body.copyWith(
                            color: MacosColors.systemGrayColor.resolveFrom(
                              context,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        for (final level in widget.levels) ...[
                          _LevelCard(
                            level: level,
                            progress:
                                _progressByLevel[level.id] ??
                                const LevelProgress.empty(),
                            total: widget.questionsPerSession,
                            onTap: () => widget.onSelect(level),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ProgressFooter(
                    progressByLevel: _progressByLevel,
                    levelCount: widget.levels.length,
                    hasProgress: hasProgress,
                    onReset: _confirmResetProgress,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Aggregate stats for the module plus the reset control, pinned to the
/// bottom of the pane as an edge-to-edge frosted strip (mirrors the blurred
/// toolbar). Level cards scroll beneath it.
class _ProgressFooter extends StatelessWidget {
  const _ProgressFooter({
    required this.progressByLevel,
    required this.levelCount,
    required this.hasProgress,
    required this.onReset,
  });

  /// Bottom padding for the scroll list so the last level card can scroll
  /// clear of the footer (footer height plus breathing room).
  static const double scrollInset = 112;

  final Map<int, LevelProgress> progressByLevel;
  final int levelCount;
  final bool hasProgress;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final palette = GlassPalette.of(context);
    final practiced = progressByLevel.values
        .where((progress) => progress.hasPractice)
        .length;
    final sessions = progressByLevel.values.fold<int>(
      0,
      (sum, progress) => sum + progress.sessionsCompleted,
    );
    final totalCorrect = progressByLevel.values.fold<int>(
      0,
      (sum, progress) => sum + progress.totalCorrect,
    );
    final totalQuestions = progressByLevel.values.fold<int>(
      0,
      (sum, progress) => sum + progress.totalQuestions,
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: BoxDecoration(
            color: palette.fill,
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Your progress', style: theme.typography.headline),
                  const Spacer(),
                  PushButton(
                    controlSize: ControlSize.regular,
                    secondary: true,
                    onPressed: hasProgress ? onReset : null,
                    child: const Text('Reset Progress'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Stat(
                    label: 'Levels practiced',
                    value: '$practiced / $levelCount',
                  ),
                  _Stat(label: 'Sessions', value: '$sessions'),
                  _Stat(
                    label: 'Overall accuracy',
                    value: totalQuestions > 0
                        ? '${(totalCorrect / totalQuestions * 100).round()}%'
                        : '—',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.typography.title2),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.typography.subheadline.copyWith(
              color: MacosColors.systemGrayColor.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.progress,
    required this.total,
    required this.onTap,
  });

  final QuizLevel level;
  final LevelProgress progress;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: onTap,
      child: MacosListTile(
        leading: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${level.id}',
            style: theme.typography.headline.copyWith(
              color: theme.primaryColor,
            ),
          ),
        ),
        title: Text(level.name, style: theme.typography.headline),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            progress.hasPractice
                ? '${level.description}  ·  ${_progressText()}'
                : level.description,
            style: theme.typography.subheadline.copyWith(
              color: MacosColors.systemGrayColor.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }

  String _progressText() {
    final best = 'Best: ${progress.bestScore}/$total';
    if (progress.sessionsCompleted == 0) return best;
    return '$best  ·  ${_sessionText(progress.sessionsCompleted)}'
        '  ·  ${_accuracyText(progress)}';
  }

  String _sessionText(int count) =>
      count == 1 ? '1 session' : '$count sessions';

  String _accuracyText(LevelProgress progress) {
    final percent = (progress.accuracy * 100).round();
    return '$percent% accuracy';
  }
}
