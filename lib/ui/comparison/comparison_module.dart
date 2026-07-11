import 'package:flutter/widgets.dart';

import '../../models/comparison.dart';
import '../../services/comparison_question_generator.dart';
import '../quiz/level_select_page.dart';
import '../quiz/session_page.dart';

/// Interval comparison: two intervals play — which is wider?
class ComparisonModule extends StatefulWidget {
  const ComparisonModule({super.key});

  static const String scoreKeyPrefix = 'best_score_compare_level_';

  @override
  State<ComparisonModule> createState() => _ComparisonModuleState();
}

class _ComparisonModuleState extends State<ComparisonModule> {
  ComparisonLevel? _activeLevel;

  @override
  Widget build(BuildContext context) {
    final level = _activeLevel;
    if (level == null) {
      return LevelSelectPage(
        title: 'Interval Comparison',
        intro:
            'Two intervals play, one after the other — say which is wider. '
            'The sizes get closer as you level up.',
        levels: kComparisonLevels,
        scoreKeyPrefix: ComparisonModule.scoreKeyPrefix,
        questionsPerSession: 10,
        onSelect: (selected) =>
            setState(() => _activeLevel = selected as ComparisonLevel),
      );
    }
    return SessionPage(
      key: ValueKey('comparison-${level.id}'),
      level: level,
      generator: ComparisonQuestionGenerator(level),
      scoreKeyPrefix: ComparisonModule.scoreKeyPrefix,
      prompt: 'Which interval is wider?',
      playLabel: 'Play Intervals',
      onExit: () => setState(() => _activeLevel = null),
    );
  }
}
