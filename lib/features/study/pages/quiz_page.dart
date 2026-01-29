import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/card_model.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/repositories/card_repository.dart';

class QuizPage extends StatefulWidget {
  final Deck deck;
  const QuizPage({super.key, required this.deck});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final CardRepository _repo = CardRepository();
  List<CardModel> _questions = [];
  List<String> _currentOptions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _showResult = false;
  String? _selectedAnswer;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final cards = await _repo.getCardsByDeckId(widget.deck.id!);
    if (cards.length < 4) {
      // Not enough cards for quiz
      if (mounted) {
        setState(() {
          _questions = cards; // Still load what we have
          _isLoading = false;
        });
      }
      return;
    }

    cards.shuffle(); // Randomize order
    setState(() {
      _questions = cards;
      _isLoading = false;
      _generateOptions();
    });
  }

  void _generateOptions() {
    if (_currentIndex >= _questions.length) {
      return;
    }

    final currentCard = _questions[_currentIndex];
    final options = <String>[currentCard.definition];

    // Pick 3 random distractors from other cards
    final otherCards = List<CardModel>.from(_questions)
      ..removeWhere((c) => c.id == currentCard.id);
    otherCards.shuffle();

    for (int i = 0; i < 3 && i < otherCards.length; i++) {
      options.add(otherCards[i].definition);
    }

    options.shuffle(); // Shuffle positions
    _currentOptions = options;
  }

  void _submitAnswer(String answer) {
    if (_isAnswered) {
      return;
    }

    final isCorrect = answer == _questions[_currentIndex].definition;
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      if (isCorrect) _score++;
    });

    // Auto next after delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedAnswer = null;
          _generateOptions();
        });
      } else {
        setState(() {
          _showResult = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(
          child: Text("Not enough cards for a quiz (Need at least 4)."),
        ),
      );
    }

    if (_showResult) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                "Quiz Complete!",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                "Score: $_score / ${_questions.length}",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Dashboard"),
              ),
            ],
          ),
        ),
      );
    }

    final card = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Quiz: ${widget.deck.name}"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "Score: $_score",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CallbackShortcuts(
        bindings: {
          for (int i = 0; i < _currentOptions.length; i++)
            SingleActivator(LogicalKeyboardKey(49 + i)): () =>
                _submitAnswer(_currentOptions[i]),
        },
        child: Focus(
          autofocus: true,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: const AlwaysStoppedAnimation(
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Question
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        card.term,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Options
                Expanded(
                  flex: 6,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _currentOptions.length,
                    itemBuilder: (context, index) {
                      final option = _currentOptions[index];
                      final isSelected = option == _selectedAnswer;
                      final isCorrectOption = option == card.definition;

                      Color color = Theme.of(context).colorScheme.surface;
                      Color textColor = Theme.of(context).colorScheme.onSurface;

                      if (_isAnswered) {
                        if (isCorrectOption) {
                          color = AppTheme.successColor;
                          textColor = Colors.white;
                        } else if (isSelected && !isCorrectOption) {
                          color = AppTheme.errorColor;
                          textColor = Colors.white;
                        } else {
                          color = Theme.of(
                            context,
                          ).disabledColor.withOpacity(0.1); // Disable others
                          textColor = Theme.of(context).disabledColor;
                        }
                      }

                      return ElevatedButton(
                        onPressed: _isAnswered
                            ? null
                            : () => _submitAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _isAnswered ? 0 : 2,
                        ),
                        child: Text(
                          "${index + 1}. $option",
                          style: const TextStyle(fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
