import 'package:flutter/material.dart';
import '../../../data/models/card_model.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/repositories/card_repository.dart';
import '../../../data/repositories/deck_repository.dart';

class EditorProvider extends ChangeNotifier {
  final CardRepository _repository = CardRepository();

  List<CardModel> _cards = [];
  bool _isLoading = false;
  int? _currentDeckId;

  List<CardModel> get cards => _cards;
  bool get isLoading => _isLoading;

  Future<void> loadCards(int deckId) async {
    _currentDeckId = deckId;
    _isLoading = true;
    notifyListeners();

    try {
      _cards = await _repository.getCardsByDeckId(deckId);
    } catch (e) {
      debugPrint("Error loading cards: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCard(String term, String definition) async {
    if (_currentDeckId == null) return;

    final newCard = CardModel(
      deckId: _currentDeckId!,
      term: term,
      definition: definition,
    );

    await _repository.createCard(newCard);
    await loadCards(_currentDeckId!);
  }

  Future<void> updateCard(CardModel card) async {
    await _repository.updateCard(card);
    // Optimistic update for UI speed
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _cards[index] = card;
      notifyListeners();
    }
  }

  Future<void> deleteCard(int id) async {
    await _repository.deleteCard(id);
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> updateDeck(Deck deck) async {
    final deckRepo = DeckRepository();
    await deckRepo.updateDeck(deck);
    notifyListeners();
  }
}
