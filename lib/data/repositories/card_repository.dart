import '../models/card_model.dart';
import '../datasources/database_helper.dart';

class CardRepository {
  Future<List<CardModel>> getCardsByDeckId(int deckId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'cards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
      orderBy: 'id DESC', // Newest first
    );
    return result.map((json) => CardModel.fromMap(json)).toList();
  }

  Future<int> createCard(CardModel card) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('cards', card.toMap());
  }

  Future<int> updateCard(CardModel card) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
