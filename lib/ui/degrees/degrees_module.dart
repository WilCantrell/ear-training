import 'package:flutter/widgets.dart';

import '../../models/degree.dart';
import '../../services/degree_question_generator.dart';
import '../quiz/level_select_page.dart';
import '../quiz/session_page.dart';

/// Scale-degree recognition: a cadence establishes the key, then the user
/// names the degree of a single note.
class DegreesModule extends StatefulWidget {
  const DegreesModule({super.key});

  static const String scoreKeyPrefix = 'best_score_degree_level_';

  @override
  State<DegreesModule> createState() => _DegreesModuleState();
}

class _DegreesModuleState extends State<DegreesModule> {
  DegreeLevel? _activeLevel;

  @override
  Widget build(BuildContext context) {
    final level = _activeLevel;
    if (level == null) {
      return LevelSelectPage(
        title: 'Scale Degrees',
        intro:
            'A cadence sets the key, then one note plays — name its scale '
            'degree. The key changes every question.',
        levels: kDegreeLevels,
        scoreKeyPrefix: DegreesModule.scoreKeyPrefix,
        questionsPerSession: 10,
        onSelect: (selected) =>
            setState(() => _activeLevel = selected as DegreeLevel),
      );
    }
    return SessionPage(
      key: ValueKey('degrees-${level.id}'),
      level: level,
      generator: DegreeQuestionGenerator(level),
      scoreKeyPrefix: DegreesModule.scoreKeyPrefix,
      prompt: 'Which scale degree is this?',
      playLabel: 'Play Cadence',
      onExit: () => setState(() => _activeLevel = null),
    );
  }
}
