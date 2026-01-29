import 'package:flutter/material.dart';
import '../../../data/models/card_model.dart';
import '../../../data/repositories/card_repository.dart';
import '../../../core/algorithms/sm2_algorithm.dart';

enum LearnStep {
  intro, // Show term first (Quizlet style intro)
  quiz, // Multiple choice (Recognition)
  typing, // Typing exact answer (Recall)
  checkResult, // Show Correct/Wrong feedback
  finished, // End of session
}

enum CardStatus {
  notStudied, // Haven't seen yet
  stillLearning, // Got wrong or just started
  familiar, // Got right once in quiz
  mastered, // Got right in typing (session complete)
}

class LearnCardState {
  CardModel card;
  int sessionStreak; // 0: New, 1: Recognized (quiz), 2: Mastered (typing)
  CardStatus status;
  int wrongCount; // Track wrong attempts

  LearnCardState({
    required this.card,
    this.sessionStreak = 0,
    this.status = CardStatus.notStudied,
    this.wrongCount = 0,
  });
}

class LearnController extends ChangeNotifier {
  final CardRepository _repo = CardRepository();

  // All cards for this session (for generating quiz options)
  List<CardModel> _allCards = [];

  // Data Queues
  List<CardModel> _pool = []; // Cards waiting to enter round
  List<LearnCardState> _round = []; // Active max 7 cards

  // Current State
  LearnStep _step = LearnStep.intro;
  bool _isLoading = false;

  // Feedback Data
  bool _lastAnswerCorrect = false;
  String _lastUserAnswer = '';
  List<String> _quizOptions = [];
  LearnStep _previousStep =
      LearnStep.quiz; // Track if wrong from quiz or typing

  // Statistics
  int _totalCards = 0;
  int _masteredCount = 0;
  int _familiarCount = 0;
  int _stillLearningCount = 0;
  int _correctStreak = 0;
  int _longestStreak = 0;

  // Getters
  bool get isLoading => _isLoading;
  LearnStep get step => _step;
  LearnCardState? get currentCardState => _round.isNotEmpty ? _round[0] : null;
  CardModel? get currentCard => currentCardState?.card;
  bool get lastAnswerCorrect => _lastAnswerCorrect;
  String get lastUserAnswer => _lastUserAnswer;
  List<String> get quizOptions => _quizOptions;
  LearnStep get previousStep =>
      _previousStep; // Was it quiz or typing when answered wrong?

  // Stats Getters
  int get poolRemaining => _pool.length;
  int get roundRemaining => _round.length;
  int get totalCards => _totalCards;
  int get masteredCount => _masteredCount;
  int get familiarCount => _familiarCount;
  int get stillLearningCount => _stillLearningCount;
  int get correctStreak => _correctStreak;
  int get longestStreak => _longestStreak;

  // Progress as percentage (0.0 - 1.0)
  double get progressPercent {
    if (_totalCards == 0) return 0.0;
    return _masteredCount / _totalCards;
  }

  // Cards left to master
  int get cardsRemaining => _totalCards - _masteredCount;

  Future<void> startSession(int deckId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allCards = await _repo.getCardsByDeckId(deckId);

      // Store all cards for quiz option generation
      _allCards = List.from(allCards);
      _totalCards = allCards.length;

      // Shuffle and prepare
      allCards.shuffle();
      _pool = allCards;

      // Reset stats
      _masteredCount = 0;
      _familiarCount = 0;
      _stillLearningCount = 0;
      _correctStreak = 0;
      _longestStreak = 0;

      _fillRound();
      _prepareCard();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _fillRound() {
    if (_round.isNotEmpty) return;

    // Pull up to 7 cards from pool
    int count = 0;
    while (_pool.isNotEmpty && count < 7) {
      final card = _pool.removeAt(0);
      _round.add(LearnCardState(card: card));
      _stillLearningCount++;
      count++;
    }

    if (_round.isEmpty && _pool.isEmpty) {
      _step = LearnStep.finished;
    }
  }

  void _prepareCard() {
    if (_round.isEmpty) {
      _fillRound();
      if (_round.isEmpty) {
        _step = LearnStep.finished;
        notifyListeners();
        return;
      }
    }

    final state = _round[0];

    // Update status if first time seeing this card
    if (state.status == CardStatus.notStudied) {
      state.status = CardStatus.stillLearning;
    }

    // Determine Step based on Session Streak
    // Streak 0: Quiz mode (multiple choice - recognition)
    // Streak 1+: Typing mode (recall)
    if (state.sessionStreak == 0) {
      _step = LearnStep.quiz;
      _generateQuizOptions();
    } else {
      _step = LearnStep.typing;
    }

    notifyListeners();
  }

  void _generateQuizOptions() {
    if (currentCard == null) return;

    _quizOptions = [currentCard!.definition];

    // Get other card definitions as distractors
    final otherCards = _allCards.where((c) => c.id != currentCard!.id).toList();
    otherCards.shuffle();

    // Add up to 3 distractors
    int added = 0;
    for (var card in otherCards) {
      if (added >= 3) break;
      // Avoid duplicate definitions
      if (!_quizOptions.contains(card.definition)) {
        _quizOptions.add(card.definition);
        added++;
      }
    }

    // If not enough cards, add some placeholder (shouldn't happen normally)
    while (_quizOptions.length < 4) {
      _quizOptions.add("—"); // Empty option indicator
    }

    _quizOptions.shuffle();
  }

  Future<void> submitAnswer(String answer) async {
    if (currentCard == null) return;

    _lastUserAnswer = answer;
    _previousStep = _step; // Save current step before changing to checkResult

    // Fuzzy match: case insensitive, trim whitespace
    final userAnswer = answer.trim().toLowerCase();
    final correctAnswer = currentCard!.definition.trim().toLowerCase();

    // More lenient matching for typing
    final correct = _isAnswerCorrect(userAnswer, correctAnswer);

    _lastAnswerCorrect = correct;
    _step = LearnStep.checkResult;

    // Update streak
    if (correct) {
      _correctStreak++;
      if (_correctStreak > _longestStreak) {
        _longestStreak = _correctStreak;
      }
    } else {
      _correctStreak = 0;
    }

    notifyListeners();

    // Process Result
    final state = _round.removeAt(0);

    if (correct) {
      state.sessionStreak++;

      if (state.sessionStreak >= 2) {
        // Mastered! Card leaves the round
        if (state.status != CardStatus.mastered) {
          if (state.status == CardStatus.familiar) _familiarCount--;
          if (state.status == CardStatus.stillLearning) _stillLearningCount--;
          state.status = CardStatus.mastered;
          _masteredCount++;
        }

        // Save to DB with SM-2 update
        final rating = state.wrongCount == 0 ? 4 : 3; // Easy if no mistakes
        final newCard = SpacedRepetition.calculate(state.card, rating);
        await _repo.updateCard(newCard);

        // Don't put back in round
      } else {
        // First correct (quiz) -> Now familiar, will do typing next
        if (state.status == CardStatus.stillLearning) {
          _stillLearningCount--;
          state.status = CardStatus.familiar;
          _familiarCount++;
        }
        // Put at end of round for typing test
        _round.add(state);
      }
    } else {
      // Wrong -> Reset streak, back to start
      state.wrongCount++;
      state.sessionStreak = 0;

      if (state.status == CardStatus.familiar) {
        _familiarCount--;
        state.status = CardStatus.stillLearning;
        _stillLearningCount++;
      }

      _round.add(state);

      // Apply SM-2 penalty
      final punishedCard = SpacedRepetition.calculate(state.card, 1);
      await _repo.updateCard(punishedCard);
      state.card = punishedCard;
    }
  }

  bool _isAnswerCorrect(String userAnswer, String correctAnswer) {
    // Exact match
    if (userAnswer == correctAnswer) return true;

    // Allow minor typos for long answers (Levenshtein-like simple check)
    if (correctAnswer.length > 5) {
      final similarity = _calculateSimilarity(userAnswer, correctAnswer);
      if (similarity > 0.85) return true; // 85% match is acceptable
    }

    return false;
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Simple character overlap ratio
    int matches = 0;

    for (int i = 0; i < s1.length && i < s2.length; i++) {
      if (s1[i] == s2[i]) matches++;
    }

    return matches / (s1.length > s2.length ? s1.length : s2.length);
  }

  void nextCard() {
    _prepareCard();
  }

  void skipCard() {
    if (_round.isEmpty) return;

    // Move current card to end without penalty
    final state = _round.removeAt(0);
    _round.add(state);
    _prepareCard();
  }

  // Restart the session
  Future<void> restartSession(int deckId) async {
    _round.clear();
    _pool.clear();
    await startSession(deckId);
  }
}
