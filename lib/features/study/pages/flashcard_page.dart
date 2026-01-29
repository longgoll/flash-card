import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/card_model.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/repositories/card_repository.dart';

class FlashcardPage extends StatefulWidget {
  final Deck deck;
  const FlashcardPage({super.key, required this.deck});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  final CardRepository _repo = CardRepository();
  List<CardModel> _cards = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  // Flip Animation
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _loadCards();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final cards = await _repo.getCardsByDeckId(widget.deck.id!);
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
  }

  void _flipCard() {
    if (_controller.isAnimating) return;

    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _showFront = !_showFront;
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      if (!_showFront) {
        _controller.reset(); // Reset to front instantly for next card
        _showFront = true;
      }
      setState(() => _currentIndex++);
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      if (!_showFront) {
        _controller.reset();
        _showFront = true;
      }
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Flashcards: ${widget.deck.name}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _isLoading ? "--/--" : "${_currentIndex + 1}/${_cards.length}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.space): _flipCard,
          const SingleActivator(LogicalKeyboardKey.arrowRight): _nextCard,
          const SingleActivator(LogicalKeyboardKey.arrowLeft): _prevCard,
        },
        child: Focus(
          autofocus: true,
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : _cards.isEmpty
                ? const Text("No cards in this deck.")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Card Area
                      GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final angle = _animation.value * pi;
                            final transform = Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateY(angle);

                            return Transform(
                              transform: transform,
                              alignment: Alignment.center,
                              child: _animation.value < 0.5
                                  ? _buildFace(isFront: true)
                                  : Transform(
                                      transform: Matrix4.identity()
                                        ..rotateY(pi), // Flip back face content
                                      alignment: Alignment.center,
                                      child: _buildFace(isFront: false),
                                    ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _prevCard,
                            icon: const Icon(Icons.arrow_back_ios),
                            tooltip: "Previous (Left Arrow)",
                          ),
                          const SizedBox(width: 32),
                          ElevatedButton.icon(
                            onPressed: _flipCard,
                            icon: const Icon(Icons.flip),
                            label: const Text("FLIP (Space)"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            onPressed: _nextCard,
                            icon: const Icon(Icons.arrow_forward_ios),
                            tooltip: "Next (Right Arrow)",
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFace({required bool isFront}) {
    final card = _cards[_currentIndex];
    return Container(
      width: 600,
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isFront ? "TERM" : "DEFINITION",
              style: TextStyle(
                color: isFront
                    ? AppTheme.primaryColor
                    : AppTheme.secondaryColor,
                letterSpacing: 2,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFront ? card.term : card.definition,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
