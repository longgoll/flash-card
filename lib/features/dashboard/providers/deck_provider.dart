import 'package:flutter/material.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/repositories/deck_repository.dart';

class DeckProvider extends ChangeNotifier {
  final DeckRepository _repository = DeckRepository();

  List<Deck> _decks = [];
  bool _isLoading = false;

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;

  Future<void> loadDecks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _decks = await _repository.getAllDecks();
    } catch (e) {
      debugPrint("Error loading decks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeck(String name, String description) async {
    final newDeck = Deck(
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    await _repository.createDeck(newDeck);
    await loadDecks(); // Reload list
  }

  Future<void> deleteDeck(int id) async {
    await _repository.deleteDeck(id);
    await loadDecks(); // Reload list
  }

  Future<void> updateDeck(Deck deck) async {
    await _repository.updateDeck(deck);
    await loadDecks();
  }
}
