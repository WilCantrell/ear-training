import 'package:flutter/widgets.dart';

import '../../models/level.dart';
import '../../services/question_generator.dart';
import '../quiz/level_select_page.dart';
import '../quiz/session_page.dart';

/// Chords module: pick a level, then practice identifying chord qualities.
class ChordsModule extends StatefulWidget {
  const ChordsModule({super.key});

  static const String scoreKeyPrefix = 'best_score_level_';

  @override
  State<ChordsModule> createState() => _ChordsModuleState();
}

class _ChordsModuleState extends State<ChordsModule> {
  Level? _activeLevel;

  @override
  Widget build(BuildContext context) {
    final level = _activeLevel;
    if (level == null) {
      return LevelSelectPage(
        title: 'Chords',
        intro: 'A chord plays — identify its quality. Difficulty grows with '
            'chord complexity and inversions.',
        levels: kChordLevels,
        scoreKeyPrefix: ChordsModule.scoreKeyPrefix,
        questionsPerSession: 10,
        onSelect: (selected) =>
            setState(() => _activeLevel = selected as Level),
      );
    }
    return SessionPage(
      key: ValueKey('chords-${level.id}'),
      level: level,
      generator: ChordQuestionGenerator(level),
      scoreKeyPrefix: ChordsModule.scoreKeyPrefix,
      prompt: 'Which chord is this?',
      playLabel: 'Play Chord',
      onExit: () => setState(() => _activeLevel = null),
    );
  }
}
