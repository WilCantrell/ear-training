import 'package:flutter/widgets.dart';

import '../../models/interval_level.dart';
import '../../services/interval_question_generator.dart';
import '../quiz/level_select_page.dart';
import '../quiz/session_page.dart';

/// Intervals module: pick a level, then practice identifying intervals.
class IntervalsModule extends StatefulWidget {
  const IntervalsModule({super.key});

  static const String scoreKeyPrefix = 'best_score_interval_level_';

  @override
  State<IntervalsModule> createState() => _IntervalsModuleState();
}

class _IntervalsModuleState extends State<IntervalsModule> {
  IntervalLevel? _activeLevel;

  @override
  Widget build(BuildContext context) {
    final level = _activeLevel;
    if (level == null) {
      return LevelSelectPage(
        title: 'Intervals',
        intro: 'Two notes play — identify the interval between them. '
            'Difficulty grows with the intervals, direction, and harmony.',
        levels: kIntervalLevels,
        scoreKeyPrefix: IntervalsModule.scoreKeyPrefix,
        questionsPerSession: 10,
        onSelect: (selected) =>
            setState(() => _activeLevel = selected as IntervalLevel),
      );
    }
    return SessionPage(
      key: ValueKey('intervals-${level.id}'),
      level: level,
      generator: IntervalQuestionGenerator(level),
      scoreKeyPrefix: IntervalsModule.scoreKeyPrefix,
      prompt: 'Which interval is this?',
      playLabel: 'Play Interval',
      onExit: () => setState(() => _activeLevel = null),
    );
  }
}
