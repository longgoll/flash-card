import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/repositories/card_repository.dart';

class MatchPage extends StatefulWidget {
  final Deck deck;
  const MatchPage({super.key, required this.deck});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchItem {
  final String id;
  final int cardId;
  final String text;
  final bool isTerm;
  bool isMatched;
  bool isSelected;
  bool isCorrect;
  bool isWrong;

  _MatchItem({
    required this.id,
    required this.cardId,
    required this.text,
    required this.isTerm,
    this.isMatched = false,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
  });
}

class _MatchPageState extends State<MatchPage> with TickerProviderStateMixin {
  final CardRepository _repo = CardRepository();
  List<_MatchItem> _terms = [];
  List<_MatchItem> _definitions = [];
  bool _isLoading = true;
  bool _isGameCompleted = false;

  Timer? _timer;
  int _secondsElapsed = 0;
  int _matchedPairs = 0;
  int _totalPairs = 0;

  _MatchItem? _selectedTerm;
  _MatchItem? _selectedDefinition;

  // Animation controllers for matched items
  final Map<String, AnimationController> _fadeControllers = {};

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _fadeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  Future<void> _loadGame() async {
    setState(() => _isLoading = true);
    final cards = await _repo.getCardsByDeckId(widget.deck.id!);

    if (cards.length < 3) {
      if (mounted) {
        setState(() {
          _terms = [];
          _definitions = [];
          _isLoading = false;
        });
      }
      return;
    }

    cards.shuffle();
    final gameCards = cards.take(6).toList();

    List<_MatchItem> terms = [];
    List<_MatchItem> definitions = [];

    for (var card in gameCards) {
      terms.add(
        _MatchItem(
          id: '${card.id}_term',
          cardId: card.id!,
          text: card.term,
          isTerm: true,
        ),
      );
      definitions.add(
        _MatchItem(
          id: '${card.id}_def',
          cardId: card.id!,
          text: card.definition,
          isTerm: false,
        ),
      );
    }

    // Shuffle both lists independently
    terms.shuffle();
    definitions.shuffle();

    // Clear old animation controllers
    for (var controller in _fadeControllers.values) {
      controller.dispose();
    }
    _fadeControllers.clear();

    if (mounted) {
      setState(() {
        _terms = terms;
        _definitions = definitions;
        _isLoading = false;
        _secondsElapsed = 0;
        _matchedPairs = 0;
        _totalPairs = gameCards.length;
        _isGameCompleted = false;
        _selectedTerm = null;
        _selectedDefinition = null;
      });
      _startTimer();
    }
  }

  void _onTermTap(_MatchItem term) {
    if (term.isMatched) return;

    setState(() {
      // Deselect previous term if any
      if (_selectedTerm != null) {
        _selectedTerm!.isSelected = false;
      }

      // Select new term
      term.isSelected = true;
      _selectedTerm = term;
    });

    // Check for match if definition is already selected
    _checkForMatch();
  }

  void _onDefinitionTap(_MatchItem definition) {
    if (definition.isMatched) return;

    setState(() {
      // Deselect previous definition if any
      if (_selectedDefinition != null) {
        _selectedDefinition!.isSelected = false;
      }

      // Select new definition
      definition.isSelected = true;
      _selectedDefinition = definition;
    });

    // Check for match if term is already selected
    _checkForMatch();
  }

  void _checkForMatch() {
    if (_selectedTerm == null || _selectedDefinition == null) return;

    final term = _selectedTerm!;
    final definition = _selectedDefinition!;

    if (term.cardId == definition.cardId) {
      // Correct match!
      setState(() {
        term.isCorrect = true;
        definition.isCorrect = true;
        term.isSelected = false;
        definition.isSelected = false;
      });

      // Animate out after short delay
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() {
          term.isMatched = true;
          definition.isMatched = true;
          term.isCorrect = false;
          definition.isCorrect = false;
          _matchedPairs++;
          _selectedTerm = null;
          _selectedDefinition = null;
        });
        _checkWin();
      });
    } else {
      // Wrong match!
      setState(() {
        term.isWrong = true;
        definition.isWrong = true;
        _secondsElapsed += 2; // Penalty
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          term.isWrong = false;
          definition.isWrong = false;
          term.isSelected = false;
          definition.isSelected = false;
          _selectedTerm = null;
          _selectedDefinition = null;
        });
      });
    }
  }

  void _checkWin() {
    if (_matchedPairs >= _totalPairs) {
      _timer?.cancel();
      setState(() {
        _isGameCompleted = true;
      });
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              _isGameCompleted ? l10n.done : _formatTime(_secondsElapsed),
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isLoading && !_isGameCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  '$_matchedPairs / $_totalPairs',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGame,
            tooltip: l10n.restart,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_terms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCardsInDeck,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addCardsFirst,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (_isGameCompleted) {
      return _buildCompletedView();
    }

    return _buildGameView();
  }

  Widget _buildCompletedView() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Trophy with glow effect
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amber.withOpacity(0.3),
                  Colors.amber.withOpacity(0.0),
                ],
              ),
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 100,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "${l10n.congratulations} 🎉",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_secondsElapsed),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.back),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadGame,
                icon: const Icon(Icons.replay),
                label: Text(l10n.playAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Instructions (keep in English for now, simple enough)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.translate('match_instruction'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Game Grid
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Terms Column (Left)
                Expanded(
                  child: Column(
                    children: [
                      _buildColumnHeader(
                        l10n.term.toUpperCase(),
                        Icons.text_fields,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _terms.length,
                          itemBuilder: (context, index) {
                            return _buildMatchCard(
                              _terms[index],
                              () => _onTermTap(_terms[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Definitions Column (Right)
                Expanded(
                  child: Column(
                    children: [
                      _buildColumnHeader(
                        l10n.definition.toUpperCase(),
                        Icons.menu_book,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _definitions.length,
                          itemBuilder: (context, index) {
                            return _buildMatchCard(
                              _definitions[index],
                              () => _onDefinitionTap(_definitions[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(_MatchItem item, VoidCallback onTap) {
    // Determine card state colors
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    double opacity = 1.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (item.isMatched) {
      // Matched - fade out
      opacity = 0.0;
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
      textColor = Colors.transparent;
    } else if (item.isCorrect) {
      // Correct match animation
      backgroundColor = AppTheme.successColor;
      borderColor = AppTheme.successColor;
      textColor = Colors.white;
    } else if (item.isWrong) {
      // Wrong match animation
      backgroundColor = AppTheme.errorColor;
      borderColor = AppTheme.errorColor;
      textColor = Colors.white;
    } else if (item.isSelected) {
      // Selected state
      backgroundColor = AppTheme.primaryColor;
      borderColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else {
      // Default state
      backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
      borderColor = isDark ? Colors.white12 : Colors.grey.withOpacity(0.2);
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.isMatched ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: item.isSelected || item.isCorrect || item.isWrong
                    ? [
                        BoxShadow(
                          color: borderColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  item.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
