import 'package:flutter/widgets.dart';

import '../../models/progression.dart';
import '../../services/progression_question_generator.dart';
import '../quiz/level_select_page.dart';
import '../quiz/session_page.dart';

/// Chord progressions: a short diatonic progression plays and the user names
/// it by its roman numerals.
class ProgressionsModule extends StatefulWidget {
  const ProgressionsModule({super.key});

  static const String scoreKeyPrefix = 'best_score_progression_level_';

  @override
  State<ProgressionsModule> createState() => _ProgressionsModuleState();
}

class _ProgressionsModuleState extends State<ProgressionsModule> {
  ProgressionLevel? _activeLevel;

  @override
  Widget build(BuildContext context) {
    final level = _activeLevel;
    if (level == null) {
      return LevelSelectPage(
        title: 'Progressions',
        intro:
            'A chord progression plays in a random key — identify it by its '
            'roman numerals.',
        levels: kProgressionLevels,
        scoreKeyPrefix: ProgressionsModule.scoreKeyPrefix,
        questionsPerSession: 10,
        onSelect: (selected) =>
            setState(() => _activeLevel = selected as ProgressionLevel),
      );
    }
    return SessionPage(
      key: ValueKey('progressions-${level.id}'),
      level: level,
      generator: ProgressionQuestionGenerator(level),
      scoreKeyPrefix: ProgressionsModule.scoreKeyPrefix,
      prompt: 'Which progression is this?',
      playLabel: 'Play Progression',
      onExit: () => setState(() => _activeLevel = null),
    );
  }
}
