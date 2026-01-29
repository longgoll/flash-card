import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/editor_provider.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/models/card_model.dart';

class EditorPage extends StatefulWidget {
  final Deck deck;

  const EditorPage({super.key, required this.deck});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _termController = TextEditingController();
  final _defController = TextEditingController();
  final _termFocus = FocusNode();
  final _defFocus = FocusNode();
  CardModel? _selectedCard;
  late Deck _currentDeck;

  @override
  void initState() {
    super.initState();
    _currentDeck = widget.deck;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditorProvider>().loadCards(widget.deck.id!);
      _termFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _termController.dispose();
    _defController.dispose();
    _termFocus.dispose();
    _defFocus.dispose();
    super.dispose();
  }

  void _selectCard(CardModel card) {
    setState(() {
      _selectedCard = card;
      _termController.text = card.term;
      _defController.text = card.definition;
    });
    _termFocus.requestFocus();
  }

  void _resetForm() {
    setState(() {
      _selectedCard = null;
      _termController.clear();
      _defController.clear();
    });
    _termFocus.requestFocus();
  }

  void _saveCard() {
    final term = _termController.text.trim();
    final def = _defController.text.trim();

    if (term.isEmpty || def.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Term and Definition cannot be empty")),
      );
      return;
    }

    if (_selectedCard != null) {
      // Update existing
      final updatedCard = _selectedCard!.copyWith(term: term, definition: def);
      context.read<EditorProvider>().updateCard(updatedCard);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Card updated!"),
          duration: Duration(milliseconds: 800),
        ),
      );
    } else {
      // Create new
      context.read<EditorProvider>().addCard(term, def);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Card saved!"),
          duration: Duration(milliseconds: 800),
        ),
      );
    }

    _resetForm();
  }

  void _editDeckName() {
    final nameController = TextEditingController(text: _currentDeck.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Deck"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: "Deck Name"),
          onSubmitted: (_) {
            _saveDeckName(nameController.text);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _saveDeckName(nameController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _saveDeckName(String newName) {
    if (newName.trim().isEmpty) return;
    setState(() {
      _currentDeck = _currentDeck.copyWith(name: newName.trim());
    });
    context.read<EditorProvider>().updateDeck(_currentDeck);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Editing: "),
            Flexible(
              child: InkWell(
                onTap: _editDeckName,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _currentDeck.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dotted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter, control: true):
              _saveCard,
          const SingleActivator(LogicalKeyboardKey.enter, meta: true):
              _saveCard, // macOS Cmd+Enter
        },
        child: Focus(
          autofocus: true,
          child: Row(
            children: [
              // LEFT SIDE: Card List
              Expanded(
                flex: 3,
                child: Container(
                  color: Theme.of(context).cardTheme.color,
                  child: Consumer<EditorProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.separated(
                        itemCount: provider.cards.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        itemBuilder: (context, index) {
                          final card = provider.cards[index];
                          final isSelected = _selectedCard?.id == card.id;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: AppTheme.primaryColor
                                .withOpacity(0.1),
                            onTap: () => _selectCard(card),
                            title: Text(
                              card.term,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              card.definition,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () {
                                if (_selectedCard?.id == card.id) {
                                  _resetForm();
                                }
                                provider.deleteCard(card.id!);
                              },
                            ),
                            dense: true,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // RIGHT SIDE: Input Form
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCard != null ? "Edit Card" : "New Card",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (_selectedCard != null)
                            TextButton.icon(
                              onPressed: _resetForm,
                              icon: const Icon(Icons.add),
                              label: const Text("Create New Instead"),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Term Input
                      Text(
                        "Term",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _termController,
                        focusNode: _termFocus,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: "Enter term...",
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _defFocus.requestFocus(),
                      ),

                      const SizedBox(height: 24),

                      // Definition Input
                      Text(
                        "Definition",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _defController,
                          focusNode: _defFocus,
                          style: const TextStyle(fontSize: 18),
                          maxLines: null, // Multiline
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: "Enter definition...",
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Press Ctrl + Enter to save",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color?.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _saveCard,
                            icon: Icon(
                              _selectedCard != null ? Icons.edit : Icons.save,
                            ),
                            label: Text(
                              _selectedCard != null
                                  ? "Update Card"
                                  : "Save Card",
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
