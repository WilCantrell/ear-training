import 'package:eartraining/models/quiz.dart';
import 'package:eartraining/state/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const levelOne = _TestLevel(1);
  const levelTwo = _TestLevel(2);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressStore', () {
    test('recordSession updates best score and aggregate progress', () async {
      const store = ProgressStore('test_progress_');

      var progress = await store.recordSession(
        level: levelOne,
        score: 7,
        totalQuestions: 10,
      );

      expect(progress.bestScore, 7);
      expect(progress.sessionsCompleted, 1);
      expect(progress.totalCorrect, 7);
      expect(progress.totalQuestions, 10);
      expect(progress.accuracy, 0.7);

      progress = await store.recordSession(
        level: levelOne,
        score: 4,
        totalQuestions: 10,
      );

      expect(progress.bestScore, 7);
      expect(progress.sessionsCompleted, 2);
      expect(progress.totalCorrect, 11);
      expect(progress.totalQuestions, 20);
      expect(progress.accuracy, 0.55);
    });

    test(
      'loadAll returns empty progress for levels without saved data',
      () async {
        const store = ProgressStore('test_progress_');

        await store.recordSession(
          level: levelOne,
          score: 9,
          totalQuestions: 10,
        );

        final progress = await store.loadAll(const [levelOne, levelTwo]);

        expect(progress[levelOne.id]!.bestScore, 9);
        expect(progress[levelOne.id]!.sessionsCompleted, 1);
        expect(progress[levelTwo.id]!.hasPractice, isFalse);
      },
    );

    test('resetAll clears best scores and aggregate progress', () async {
      const store = ProgressStore('test_progress_');

      await store.recordSession(level: levelOne, score: 8, totalQuestions: 10);

      await store.resetAll(const [levelOne]);

      final progress = await store.load(levelOne);
      expect(progress.hasPractice, isFalse);
      expect(progress.bestScore, 0);
      expect(progress.sessionsCompleted, 0);
      expect(progress.totalCorrect, 0);
      expect(progress.totalQuestions, 0);
    });
  });
}

class _TestLevel implements QuizLevel {
  const _TestLevel(this.id);

  @override
  final int id;

  @override
  String get name => 'Level $id';

  @override
  String get description => 'Test level $id';
}
