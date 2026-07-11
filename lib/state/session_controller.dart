import 'package:flutter/foundation.dart';

import '../models/quiz.dart';
import '../models/sound_type.dart';
import '../services/audio_engine.dart';
import 'progress_store.dart';

enum SessionPhase { awaitingAnswer, answered, finished }

/// Drives a single practice session for any module: question sequence,
/// scoring, audio playback and progress persistence. It works against the
/// [QuizQuestion]/[QuizGenerator] abstractions, so it's shared by chords,
/// intervals and any future module.
class SessionController extends ChangeNotifier {
  SessionController({
    required this.level,
    required AudioEngine audio,
    required QuizGenerator generator,
    required this.scoreKeyPrefix,
    this.questionsPerSession = 10,
  }) : _audio = audio,
       _generator = generator,
       _progressStore = ProgressStore(scoreKeyPrefix);

  final QuizLevel level;
  final AudioEngine _audio;
  final QuizGenerator _generator;
  final ProgressStore _progressStore;

  /// Distinguishes saved best scores between modules, e.g. "best_score_level_"
  /// for chords vs "best_score_interval_level_" for intervals.
  final String scoreKeyPrefix;
  final int questionsPerSession;

  SessionPhase _phase = SessionPhase.awaitingAnswer;
  SessionPhase get phase => _phase;

  int _questionIndex = 0;
  int get questionNumber => _questionIndex + 1;

  int _score = 0;
  int get score => _score;

  int _streak = 0;
  int get streak => _streak;

  int _bestScore = 0;
  int get bestScore => _bestScore;

  QuizQuestion? _question;
  QuizQuestion? get question => _question;

  Labeled? _selected;
  Labeled? get selected => _selected;

  bool get isCorrect => _selected != null && _selected == _question?.answer;

  Uint8List _currentWav = Uint8List(0);

  /// The current question's notes to light up on the keyboard.
  List<int> get currentNotes => _question?.notesToHighlight ?? const [];

  /// Loads the persisted best score and presents the first question.
  Future<void> start() async {
    final progress = await _progressStore.load(level);
    _bestScore = progress.bestScore;
    _loadQuestion();
    notifyListeners();
    await play();
  }

  void _loadQuestion() {
    final q = _generator.next();
    _question = q;
    _selected = null;
    _phase = SessionPhase.awaitingAnswer;
    _renderQuestion(q);
  }

  void _renderQuestion(QuizQuestion q) {
    final events = q.events;
    if (events != null) {
      _currentWav = _audio.renderEventsToWav(events, pureTones: q.pureTones);
    } else if (q.playTogether) {
      _currentWav = _audio.renderChordToWav(q.notesToPlay);
    } else {
      // Play longer runs (scales) faster than short ones (intervals).
      final brisk = q.notesToPlay.length > 3;
      _currentWav = _audio.renderSequenceToWav(
        q.notesToPlay,
        noteSeconds: brisk ? 0.42 : 0.95,
        gapSeconds: brisk ? 0.04 : 0.12,
      );
    }
  }

  SoundType get soundType => _audio.soundType;

  /// Switches timbre mid-session: updates the engine (which persists the
  /// choice) and re-renders the current question's cached WAV so Replay uses
  /// the new sound immediately. Deliberately no auto-play.
  Future<void> setSoundType(SoundType type) async {
    if (type == _audio.soundType) return;
    await _audio.setSoundType(type);
    final q = _question;
    if (q != null && _phase != SessionPhase.finished) _renderQuestion(q);
    notifyListeners();
  }

  /// Plays (or replays) the current question's audio.
  Future<void> play() async {
    if (_currentWav.isEmpty) return;
    await _audio.playRendered(_currentWav);
  }

  /// Records the user's choice and reveals the result.
  void answer(Labeled choice) {
    if (_phase != SessionPhase.awaitingAnswer) return;
    _selected = choice;
    _phase = SessionPhase.answered;
    if (choice == _question!.answer) {
      _score++;
      _streak++;
    } else {
      _streak = 0;
    }
    notifyListeners();
  }

  /// Advances to the next question, or finishes the session.
  Future<void> next() async {
    if (_phase == SessionPhase.finished) return;
    if (_questionIndex + 1 >= questionsPerSession) {
      _phase = SessionPhase.finished;
      await _persistProgress();
      notifyListeners();
      return;
    }
    _questionIndex++;
    _loadQuestion();
    notifyListeners();
    await play();
  }

  Future<void> _persistProgress() async {
    final progress = await _progressStore.recordSession(
      level: level,
      score: _score,
      totalQuestions: questionsPerSession,
    );
    _bestScore = progress.bestScore;
  }
}
