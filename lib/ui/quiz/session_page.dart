import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../../models/quiz.dart';
import '../../models/sound_type.dart';
import '../../services/audio_engine.dart';
import '../../state/session_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/answer_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/piano_keyboard.dart';
import '../widgets/score_header.dart';

/// A practice session screen shared by every module. The module supplies the
/// level, a generator, a persistence prefix and a bit of wording.
class SessionPage extends StatelessWidget {
  const SessionPage({
    super.key,
    required this.level,
    required this.generator,
    required this.scoreKeyPrefix,
    required this.prompt,
    required this.playLabel,
    required this.onExit,
  });

  final QuizLevel level;
  final QuizGenerator generator;
  final String scoreKeyPrefix;

  /// e.g. "Which chord is this?" / "Which interval is this?"
  final String prompt;

  /// e.g. "Play Chord" / "Play Interval".
  final String playLabel;

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SessionController>(
      create: (_) => SessionController(
        level: level,
        audio: AudioEngine.instance,
        generator: generator,
        scoreKeyPrefix: scoreKeyPrefix,
      )..start(),
      child: _SessionView(level: level, prompt: prompt, playLabel: playLabel, onExit: onExit),
    );
  }
}

class _SessionView extends StatelessWidget {
  const _SessionView({
    required this.level,
    required this.prompt,
    required this.playLabel,
    required this.onExit,
  });

  final QuizLevel level;
  final String prompt;
  final String playLabel;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SessionController>();
    final theme = MacosTheme.of(context);

    return MacosScaffold(
      backgroundColor: MacosColors.transparent,
      toolBar: ToolBar(
        title: Text(level.name),
        enableBlur: true,
        decoration: BoxDecoration(
          color: theme.canvasColor.withValues(alpha: 0.5),
        ),
        leading: MacosBackButton(
          fillColor: const Color(0x00000000),
          onPressed: onExit,
        ),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(28),
                  child: GlassCard(
                    radius: 26,
                    padding: const EdgeInsets.all(28),
                    child: controller.phase == SessionPhase.finished
                        ? _Results(controller: controller, onExit: onExit)
                        : _Question(
                            controller: controller,
                            prompt: prompt,
                            playLabel: playLabel,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.controller,
    required this.prompt,
    required this.playLabel,
  });

  final SessionController controller;
  final String prompt;
  final String playLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final question = controller.question;
    if (question == null) {
      return const Center(child: ProgressCircle());
    }

    final answered = controller.phase == SessionPhase.answered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreHeader(
          questionNumber: controller.questionNumber,
          totalQuestions: controller.questionsPerSession,
          score: controller.score,
          streak: controller.streak,
        ),
        const SizedBox(height: 28),
        _PlayControls(controller: controller, playLabel: playLabel),
        const SizedBox(height: 28),
        Text(prompt, textAlign: TextAlign.center, style: theme.typography.title1),
        const SizedBox(height: 20),
        _AnswerGrid(controller: controller),
        const SizedBox(height: 24),
        // Always shown so the layout never shifts; notes only light up once the
        // user has answered. Questions that never highlight notes (pitch,
        // comparison, progressions) skip the keyboard entirely.
        if (question.notesToHighlight.isNotEmpty) ...[
          PianoKeyboard(
            highlighted: answered ? controller.currentNotes : const [],
          ),
          const SizedBox(height: 20),
        ],
        SizedBox(
          height: 44,
          child: answered
              ? _Feedback(controller: controller)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _PlayControls extends StatelessWidget {
  const _PlayControls({required this.controller, required this.playLabel});

  final SessionController controller;
  final String playLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PushButton(
          controlSize: ControlSize.large,
          onPressed: controller.play,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MacosIcon(CupertinoIcons.play_fill, size: 18),
                const SizedBox(width: 8),
                Text(playLabel),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: controller.play,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: MacosIcon(CupertinoIcons.arrow_counterclockwise),
          ),
        ),
        // Pure-tone questions (pitch discrimination) always play as sine, so
        // offering a timbre choice there would mislead.
        if (!(controller.question?.pureTones ?? false)) ...[
          const SizedBox(width: 12),
          MacosPopupButton<SoundType>(
            value: controller.soundType,
            onChanged: (type) {
              if (type != null) controller.setSoundType(type);
            },
            items: [
              for (final type in SoundType.values)
                MacosPopupMenuItem(value: type, child: Text(type.label)),
            ],
          ),
        ],
      ],
    );
  }
}

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({required this.controller});

  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final question = controller.question!;
    final answered = controller.phase == SessionPhase.answered;
    final options = question.options;

    AnswerState stateFor(Labeled option) {
      if (!answered) return AnswerState.idle;
      if (option == question.answer) return AnswerState.correct;
      if (option == controller.selected) return AnswerState.wrong;
      return AnswerState.dimmed;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns when the pane is wide enough, otherwise a single column.
        final twoColumns = options.length > 2 && constraints.maxWidth > 360;
        const spacing = 12.0;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final option in options)
              SizedBox(
                width: itemWidth,
                child: AnswerButton(
                  label: option.label,
                  state: stateFor(option),
                  onPressed: answered ? null : () => controller.answer(option),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.controller});

  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final correct = controller.isCorrect;
    final detail = controller.question!.revealLabel;
    final color = correct
        ? MacosColors.systemGreenColor.resolveFrom(context)
        : MacosColors.systemRedColor.resolveFrom(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            correct ? 'Correct — $detail' : 'Not quite — it was $detail',
            style: theme.typography.headline.copyWith(color: color),
          ),
        ),
        const SizedBox(width: 12),
        PushButton(
          controlSize: ControlSize.large,
          onPressed: controller.next,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              controller.questionNumber >= controller.questionsPerSession
                  ? 'Finish'
                  : 'Next',
            ),
          ),
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.controller, required this.onExit});

  final SessionController controller;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final total = controller.questionsPerSession;
    final score = controller.score;
    final pct = (score / total * 100).round();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        MacosIcon(
          pct >= 80
              ? CupertinoIcons.star_circle_fill
              : CupertinoIcons.checkmark_seal,
          size: 64,
          color: theme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text('Session complete', style: AppTheme.pageTitle(context)),
        const SizedBox(height: 8),
        Text('You scored $score / $total ($pct%)', style: theme.typography.title1),
        const SizedBox(height: 6),
        Text(
          'Best for this level: ${controller.bestScore}/$total',
          style: theme.typography.body.copyWith(
            color: MacosColors.systemGrayColor.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 28),
        PushButton(
          controlSize: ControlSize.large,
          onPressed: onExit,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Back to Levels'),
          ),
        ),
      ],
    );
  }
}
