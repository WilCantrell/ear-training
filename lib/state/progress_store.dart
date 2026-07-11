import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz.dart';

class LevelProgress {
  const LevelProgress({
    required this.bestScore,
    required this.sessionsCompleted,
    required this.totalCorrect,
    required this.totalQuestions,
  });

  const LevelProgress.empty()
    : bestScore = 0,
      sessionsCompleted = 0,
      totalCorrect = 0,
      totalQuestions = 0;

  final int bestScore;
  final int sessionsCompleted;
  final int totalCorrect;
  final int totalQuestions;

  double get accuracy =>
      totalQuestions == 0 ? 0 : totalCorrect / totalQuestions;

  bool get hasPractice => sessionsCompleted > 0 || bestScore > 0;

  LevelProgress copyWith({
    int? bestScore,
    int? sessionsCompleted,
    int? totalCorrect,
    int? totalQuestions,
  }) {
    return LevelProgress(
      bestScore: bestScore ?? this.bestScore,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }
}

class ProgressStore {
  const ProgressStore(this.scoreKeyPrefix);

  final String scoreKeyPrefix;

  String _bestScoreKey(int levelId) => '$scoreKeyPrefix$levelId';
  String _sessionsKey(int levelId) => '${scoreKeyPrefix}sessions_$levelId';
  String _correctKey(int levelId) => '${scoreKeyPrefix}correct_$levelId';
  String _questionsKey(int levelId) => '${scoreKeyPrefix}questions_$levelId';

  Future<LevelProgress> load(QuizLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    return LevelProgress(
      bestScore: prefs.getInt(_bestScoreKey(level.id)) ?? 0,
      sessionsCompleted: prefs.getInt(_sessionsKey(level.id)) ?? 0,
      totalCorrect: prefs.getInt(_correctKey(level.id)) ?? 0,
      totalQuestions: prefs.getInt(_questionsKey(level.id)) ?? 0,
    );
  }

  Future<Map<int, LevelProgress>> loadAll(List<QuizLevel> levels) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final level in levels)
        level.id: LevelProgress(
          bestScore: prefs.getInt(_bestScoreKey(level.id)) ?? 0,
          sessionsCompleted: prefs.getInt(_sessionsKey(level.id)) ?? 0,
          totalCorrect: prefs.getInt(_correctKey(level.id)) ?? 0,
          totalQuestions: prefs.getInt(_questionsKey(level.id)) ?? 0,
        ),
    };
  }

  Future<LevelProgress> recordSession({
    required QuizLevel level,
    required int score,
    required int totalQuestions,
  }) async {
    final current = await load(level);
    final updated = current.copyWith(
      bestScore: score > current.bestScore ? score : current.bestScore,
      sessionsCompleted: current.sessionsCompleted + 1,
      totalCorrect: current.totalCorrect + score,
      totalQuestions: current.totalQuestions + totalQuestions,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey(level.id), updated.bestScore);
    await prefs.setInt(_sessionsKey(level.id), updated.sessionsCompleted);
    await prefs.setInt(_correctKey(level.id), updated.totalCorrect);
    await prefs.setInt(_questionsKey(level.id), updated.totalQuestions);
    return updated;
  }

  Future<void> resetAll(List<QuizLevel> levels) async {
    final prefs = await SharedPreferences.getInstance();
    for (final level in levels) {
      await prefs.remove(_bestScoreKey(level.id));
      await prefs.remove(_sessionsKey(level.id));
      await prefs.remove(_correctKey(level.id));
      await prefs.remove(_questionsKey(level.id));
    }
  }
}
