import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../controllers/learn_controller.dart';
import '../../../data/models/deck_model.dart';

class LearnPage extends StatelessWidget {
  final Deck deck;

  const LearnPage({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ChangeNotifierProvider(
      create: (_) => LearnController()..startSession(deck.id!),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.learn),
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          actions: [
            Consumer<LearnController>(
              builder: (context, controller, _) {
                if (controller.isLoading) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${controller.correctStreak}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: LearnView(deck: deck),
      ),
    );
  }
}

class LearnView extends StatefulWidget {
  final Deck deck;

  const LearnView({super.key, required this.deck});

  @override
  State<LearnView> createState() => _LearnViewState();
}

class _LearnViewState extends State<LearnView> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  // Animation controllers
  late AnimationController _cardAnimController;
  late Animation<double> _cardScaleAnim;
  late AnimationController _feedbackAnimController;
  late AnimationController _flipAnimController;
  late Animation<double> _flipAnimation;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardScaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOutBack),
    );

    _feedbackAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Flip animation for intro card
    _flipAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipAnimController, curve: Curves.easeInOut),
    );

    // Confetti animation for streaks
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _cardAnimController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _cardAnimController.dispose();
    _feedbackAnimController.dispose();
    _flipAnimController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _animateCardIn() {
    _cardAnimController.reset();
    _cardAnimController.forward();
    _flipAnimController.reset(); // Reset flip for new card
  }

  void _flipCard(LearnController controller) {
    if (controller.isCardFlipped) {
      _flipAnimController.reverse();
    } else {
      _flipAnimController.forward();
    }
    controller.flipCard();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LearnController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.totalCards == 0) {
          return _buildEmptyView(context);
        }

        if (controller.step == LearnStep.finished) {
          return _buildFinishedView(context, controller);
        }

        final card = controller.currentCard;
        if (card == null) return const SizedBox();

        return Column(
          children: [
            // Progress Section
            _buildProgressSection(controller),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Question Card with animation
                    ScaleTransition(
                      scale: _cardScaleAnim,
                      child: _buildQuestionCard(context, card.term),
                    ),

                    const SizedBox(height: 32),

                    // Answer Section based on current step
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildAnswerSection(controller),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noCardsToLearn,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addCardsFirstStudy,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(LearnController controller) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: controller.progressPercent,
              minHeight: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                Icons.local_fire_department,
                "${controller.stillLearningCount}",
                l10n.stillLearning,
                Colors.orange,
              ),
              _buildStatItem(
                context,
                Icons.lightbulb_outline,
                "${controller.familiarCount}",
                l10n.familiar,
                Colors.amber,
              ),
              _buildStatItem(
                context,
                Icons.check_circle_outline,
                "${controller.masteredCount}",
                l10n.mastered,
                AppTheme.successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, String term) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Color.lerp(
              Theme.of(context).colorScheme.surface,
              AppTheme.primaryColor,
              0.05,
            )!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.term.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                letterSpacing: 2,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            term,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(LearnController controller) {
    switch (controller.step) {
      case LearnStep.intro:
        return _buildIntroView(controller);
      case LearnStep.quiz:
        return _buildQuizView(controller);
      case LearnStep.typing:
        return _buildTypingView(controller);
      case LearnStep.checkResult:
        return _buildResultView(controller);
      default:
        return const SizedBox();
    }
  }

  // Quizlet-style intro view with flip card and self-assessment
  Widget _buildIntroView(LearnController controller) {
    final l10n = AppLocalizations.of(context);
    final card = controller.currentCard!;
    final isFlipped = controller.isCardFlipped;

    return CallbackShortcuts(
      bindings: {
        // Space to flip card
        const SingleActivator(LogicalKeyboardKey.space): () =>
            _flipCard(controller),
        // 1 for Still Learning (only when flipped)
        const SingleActivator(LogicalKeyboardKey.digit1): () {
          if (isFlipped) {
            controller.handleIntroResponse(false);
            _animateCardIn();
          }
        },
        // 2 for I Know (only when flipped)
        const SingleActivator(LogicalKeyboardKey.digit2): () {
          if (isFlipped) {
            controller.handleIntroResponse(true);
            _animateCardIn();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            // Instruction text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFlipped ? Icons.check_circle_outline : Icons.touch_app,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isFlipped ? l10n.doYouKnow : l10n.tapToSeeDefinition,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Flip Card
            GestureDetector(
              onTap: () => _flipCard(controller),
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * 3.14159;
                  final isBack = _flipAnimation.value > 0.5;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isBack
                              ? [
                                  AppTheme.primaryColor.withOpacity(0.1),
                                  AppTheme.primaryColor.withOpacity(0.05),
                                ]
                              : [
                                  Theme.of(context).colorScheme.surface,
                                  Color.lerp(
                                    Theme.of(context).colorScheme.surface,
                                    AppTheme.primaryColor,
                                    0.05,
                                  )!,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isBack
                              ? AppTheme.primaryColor.withOpacity(0.3)
                              : Theme.of(context).dividerColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isBack ? AppTheme.primaryColor : Colors.black)
                                    .withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateY(isBack ? 3.14159 : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (isBack
                                            ? AppTheme.successColor
                                            : AppTheme.primaryColor)
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isBack
                                    ? l10n.definition.toUpperCase()
                                    : l10n.term.toUpperCase(),
                                style: TextStyle(
                                  color: isBack
                                      ? AppTheme.successColor
                                      : AppTheme.primaryColor,
                                  letterSpacing: 2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Content
                            Text(
                              isBack ? card.definition : card.term,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                            if (!isBack) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    size: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.tapToFlip,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Self-assessment buttons (only show when flipped)
            AnimatedOpacity(
              opacity: isFlipped ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: isFlipped ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: isFlipped
                    ? Column(
                        children: [
                          Row(
                            children: [
                              // "Still Learning" button
                              Expanded(
                                child: _buildAssessmentButton(
                                  icon: Icons.school_outlined,
                                  label: l10n.stillLearning,
                                  sublabel: l10n.showMeQuiz,
                                  color: Colors.orange,
                                  onTap: () {
                                    controller.handleIntroResponse(false);
                                    _animateCardIn();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // "I Know" button
                              Expanded(
                                child: _buildAssessmentButton(
                                  icon: Icons.check_circle_outline,
                                  label: l10n.iKnowThis,
                                  sublabel: l10n.skipToTyping,
                                  color: AppTheme.successColor,
                                  onTap: () {
                                    controller.handleIntroResponse(true);
                                    _animateCardIn();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Keyboard shortcut hint
                          Text(
                            "Space: ${l10n.tapToFlip} · 1: ${l10n.stillLearning} · 2: ${l10n.iKnowThis}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(height: 100), // Placeholder height
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizView(LearnController controller) {
    final l10n = AppLocalizations.of(context);
    final options = controller.quizOptions;

    return CallbackShortcuts(
      bindings: {
        for (int i = 0; i < options.length; i++)
          SingleActivator(LogicalKeyboardKey(49 + i)): () =>
              _handleQuizAnswer(controller, options[i]),
      },
      child: Focus(
        autofocus: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  l10n.chooseCorrectDefinition,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleQuizAnswer(controller, option),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Number badge
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuizAnswer(LearnController controller, String answer) {
    controller.submitAnswer(answer);
    _animateCardIn();
  }

  Widget _buildTypingView(LearnController controller) {
    final l10n = AppLocalizations.of(context);
    if (!_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus(),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (_textController.text.isNotEmpty) {
            _handleTypingSubmit(controller);
          }
        },
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.keyboard, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                l10n.typeTheDefinition,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: l10n.yourAnswer,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              onSubmitted: (_) => _handleTypingSubmit(controller),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  controller.skipCard();
                  _textController.clear();
                  _animateCardIn();
                },
                icon: const Icon(Icons.skip_next, size: 18),
                label: Text(l10n.skip),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _handleTypingSubmit(controller),
                icon: const Icon(Icons.check, size: 18),
                label: Text(l10n.submit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                controller.submitAnswer(""); // Give up
                _textController.clear();
                _animateCardIn();
              },
              child: Text(
                l10n.dontKnowQuestion,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTypingSubmit(LearnController controller) {
    controller.submitAnswer(_textController.text);
    _textController.clear();
    _animateCardIn();
  }

  Widget _buildResultView(LearnController controller) {
    final isCorrect = controller.lastAnswerCorrect;
    final correctAnswer = controller.currentCard!.definition;
    final userAnswer = controller.lastUserAnswer;

    if (isCorrect) {
      return _buildCorrectResult(controller);
    } else {
      return _buildIncorrectResult(controller, correctAnswer, userAnswer);
    }
  }

  Widget _buildCorrectResult(LearnController controller) {
    final l10n = AppLocalizations.of(context);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Clamp value to valid opacity range (easeOutBack can slightly overshoot)
        final clampedOpacity = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.8 + (0.2 * value.clamp(0.0, 1.0)),
          child: Opacity(opacity: clampedOpacity, child: child),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.successColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 56,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                Text(
                  l10n.correctCongrats,
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.correctStreak > 1) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${controller.correctStreak} streak!",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              controller.nextCard();
              _animateCardIn();
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.continueText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncorrectResult(
    LearnController controller,
    String correctAnswer,
    String userAnswer,
  ) {
    final l10n = AppLocalizations.of(context);
    // Check if wrong from quiz or typing
    final wasQuizMode = controller.previousStep == LearnStep.quiz;

    return Column(
      children: [
        // Wrong indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.close, color: AppTheme.errorColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notQuiteRight,
                      style: const TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userAnswer.isNotEmpty)
                      Text(
                        "${l10n.yourAnswerWas}: $userAnswer",
                        style: TextStyle(
                          color: AppTheme.errorColor.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Correct answer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.correctAnswer,
                style: TextStyle(
                  color: AppTheme.successColor.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                correctAnswer,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Quizlet style: Only require typing if wrong from TYPING mode
        // If wrong from QUIZ mode, just show Continue button
        if (wasQuizMode) ...[
          // Wrong from quiz - just show Continue button (Quizlet style)
          ElevatedButton.icon(
            onPressed: () {
              controller.nextCard();
              _animateCardIn();
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.continueText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ] else ...[
          // Wrong from typing - require typing the correct answer
          Text(
            l10n.typeCorrectToContinue,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          Builder(
            builder: (context) {
              if (!_focusNode.hasFocus) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _focusNode.requestFocus(),
                );
              }
              return TextField(
                controller: _textController,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: correctAnswer,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.2),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.errorColor,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) {
                  // Instant check - if correct, proceed
                  if (val.trim().toLowerCase() ==
                      correctAnswer.trim().toLowerCase()) {
                    _textController.clear();
                    controller.nextCard();
                    _animateCardIn();
                  }
                },
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFinishedView(BuildContext context, LearnController controller) {
    final l10n = AppLocalizations.of(context);
    final bool perfectSession =
        controller.longestStreak >= controller.totalCards;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy / Celebration
            Container(
              padding: const EdgeInsets.all(32),
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

            const SizedBox(height: 24),

            Text(
              perfectSession ? l10n.perfectRound : l10n.sessionComplete,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              l10n.masteredCards.replaceFirst(
                '{count}',
                controller.masteredCount.toString(),
              ),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Stats Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFinishStatCard(
                  context,
                  Icons.check_circle,
                  "${controller.masteredCount}",
                  l10n.mastered,
                  AppTheme.successColor,
                ),
                const SizedBox(width: 16),
                _buildFinishStatCard(
                  context,
                  Icons.local_fire_department,
                  "${controller.longestStreak}",
                  l10n.bestStreak,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Action Buttons
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
                  onPressed: () {
                    controller.restartSession(widget.deck.id!);
                    _animateCardIn();
                  },
                  icon: const Icon(Icons.replay),
                  label: Text(l10n.learnAgain),
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
      ),
    );
  }

  Widget _buildFinishStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
