import '../models/deck_model.dart';
import '../datasources/database_helper.dart';

class DeckRepository {
  Future<List<Deck>> getAllDecks() async {
    final db = await DatabaseHelper.instance.database;

    // Query Decks and count Cards in each Deck
    final result = await db.rawQuery('''
      SELECT d.*, COUNT(c.id) as card_count 
      FROM decks d 
      LEFT JOIN cards c ON d.id = c.deck_id 
      GROUP BY d.id 
      ORDER BY d.created_at DESC
    ''');

    return result.map((json) => Deck.fromMap(json)).toList();
  }

  Future<int> createDeck(Deck deck) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('decks', deck.toMap());
  }

  Future<int> updateDeck(Deck deck) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'decks',
      deck.toMap(),
      where: 'id = ?',
      whereArgs: [deck.id],
    );
  }

  Future<int> deleteDeck(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('decks', where: 'id = ?', whereArgs: [id]);
  }
}
