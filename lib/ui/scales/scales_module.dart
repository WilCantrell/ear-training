import 'package:flutter/widgets.dart';

import '../../models/scale_level.dart';
import '../../services/scale_question_generator.dart';
import '../quiz/level_select_page.dart';
import '../quiz/session_page.dart';

/// Scales module: pick a level, then practice identifying scale types.
class ScalesModule extends StatefulWidget {
  const ScalesModule({super.key});

  static const String scoreKeyPrefix = 'best_score_scale_level_';

  @override
  State<ScalesModule> createState() => _ScalesModuleState();
}

class _ScalesModuleState extends State<ScalesModule> {
  ScaleLevel? _activeLevel;

  @override
  Widget build(BuildContext context) {
    final level = _activeLevel;
    if (level == null) {
      return LevelSelectPage(
        title: 'Scales',
        intro: 'A scale plays note by note — identify which scale it is. '
            'Difficulty grows from major/minor out to modes and symmetric scales.',
        levels: kScaleLevels,
        scoreKeyPrefix: ScalesModule.scoreKeyPrefix,
        questionsPerSession: 10,
        onSelect: (selected) =>
            setState(() => _activeLevel = selected as ScaleLevel),
      );
    }
    return SessionPage(
      key: ValueKey('scales-${level.id}'),
      level: level,
      generator: ScaleQuestionGenerator(level),
      scoreKeyPrefix: ScalesModule.scoreKeyPrefix,
      prompt: 'Which scale is this?',
      playLabel: 'Play Scale',
      onExit: () => setState(() => _activeLevel = null),
    );
  }
}
