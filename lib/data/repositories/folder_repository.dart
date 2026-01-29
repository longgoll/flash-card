import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../datasources/database_helper.dart';
import '../models/folder_model.dart';
import '../models/deck_model.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create
  Future<int> createFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return await db.insert('folders', folder.toMap());
  }

  // Read All
  Future<List<Folder>> getAllFolders() async {
    final db = await _dbHelper.database;
    final result = await db.query('folders', orderBy: 'created_at DESC');
    return result.map((map) => Folder.fromMap(map)).toList();
  }

  // Read One
  Future<Folder?> getFolderById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Folder.fromMap(result.first);
    }
    return null;
  }

  // Update
  Future<int> updateFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return await db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  // Delete
  Future<int> deleteFolder(int id) async {
    final db = await _dbHelper.database;
    // Note: Due to foreign keys with CASCADE, related entries in folder_decks should be deleted automatically if configured,
    // otherwise we might need to delete them manually. We'll check ON DELETE CASCADE in schema.
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Relations (Folder <-> Deck) ---

  // Add Deck to Folder
  Future<void> addDeckToFolder(int folderId, int deckId) async {
    final db = await _dbHelper.database;
    // Ignore conflict if already exists
    await db.insert('folder_decks', {
      'folder_id': folderId,
      'deck_id': deckId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // Remove Deck from Folder
  Future<void> removeDeckFromFolder(int folderId, int deckId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'folder_decks',
      where: 'folder_id = ? AND deck_id = ?',
      whereArgs: [folderId, deckId],
    );
  }

  // Get Decks in Folder
  Future<List<Deck>> getDecksInFolder(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT d.* 
      FROM decks d
      INNER JOIN folder_decks fd ON d.id = fd.deck_id
      WHERE fd.folder_id = ?
      ORDER BY d.created_at DESC
    ''',
      [folderId],
    );

    return result.map((map) => Deck.fromMap(map)).toList();
  }

  // Get Folders for a Deck (to show which folders a deck belongs to)
  Future<List<Folder>> getFoldersForDeck(int deckId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT f.* 
      FROM folders f
      INNER JOIN folder_decks fd ON f.id = fd.folder_id
      WHERE fd.deck_id = ?
      ORDER BY f.name ASC
    ''',
      [deckId],
    );

    return result.map((map) => Folder.fromMap(map)).toList();
  }
}
