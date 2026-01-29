import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashdesk.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Init ffi loader if needed (critical for Windows/Linux)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'FlashDesk_Data', filePath);

    // Ensure directory exists
    await Directory(dirname(path)).create(recursive: true);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable Foreign Keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Decks Table
    await db.execute('''
      CREATE TABLE decks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          created_at INTEGER NOT NULL
      )
    ''');

    // 2. Cards Table
    await db.execute('''
      CREATE TABLE cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          deck_id INTEGER NOT NULL,
          
          term TEXT NOT NULL,
          definition TEXT NOT NULL,
          type TEXT DEFAULT 'text',
          
          streak INTEGER DEFAULT 0,
          ease_factor REAL DEFAULT 2.5,
          interval INTEGER DEFAULT 0,
          next_review INTEGER DEFAULT 0,
          
          review_count INTEGER DEFAULT 0,
          lapses INTEGER DEFAULT 0,
          
          FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE
      )
    ''');

    // Indexes
    await db.execute('CREATE INDEX idx_cards_deck_id ON cards(deck_id)');
    await db.execute('CREATE INDEX idx_cards_next_review ON cards(next_review)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
