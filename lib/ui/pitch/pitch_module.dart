import 'package:flutter/widgets.dart';

import '../../models/pitch.dart';
import '../../services/pitch_question_generator.dart';
import '../quiz/level_select_page.dart';
import '../quiz/session_page.dart';

/// Pitch discrimination: two pure tones — was the second higher, lower or
/// the same?
class PitchModule extends StatefulWidget {
  const PitchModule({super.key});

  static const String scoreKeyPrefix = 'best_score_pitch_level_';

  @override
  State<PitchModule> createState() => _PitchModuleState();
}

class _PitchModuleState extends State<PitchModule> {
  PitchLevel? _activeLevel;

  @override
  Widget build(BuildContext context) {
    final level = _activeLevel;
    if (level == null) {
      return LevelSelectPage(
        title: 'Pitch',
        intro:
            'Two pure tones play — was the second higher, lower or the same? '
            'The difference shrinks to a few cents as you level up. Always '
            'played as sine tones.',
        levels: kPitchLevels,
        scoreKeyPrefix: PitchModule.scoreKeyPrefix,
        questionsPerSession: 10,
        onSelect: (selected) =>
            setState(() => _activeLevel = selected as PitchLevel),
      );
    }
    return SessionPage(
      key: ValueKey('pitch-${level.id}'),
      level: level,
      generator: PitchQuestionGenerator(level),
      scoreKeyPrefix: PitchModule.scoreKeyPrefix,
      prompt: 'Was the second tone…',
      playLabel: 'Play Tones',
      onExit: () => setState(() => _activeLevel = null),
    );
  }
}
