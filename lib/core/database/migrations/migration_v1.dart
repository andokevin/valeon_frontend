// lib/core/database/migrations/migration_v1.dart
import 'package:sqflite/sqflite.dart';

class MigrationV1 {
  static Future<void> up(Database db) async {
    // Table utilisateur
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        fullName TEXT,
        photoUrl TEXT,
        subscription TEXT,
        preferences TEXT,
        lastSync TEXT,
        createdAt TEXT
      )
    ''');

    // Table scans
    await db.execute('''
      CREATE TABLE scans(
        id TEXT PRIMARY KEY,
        userId TEXT,
        type TEXT,
        inputSource TEXT,
        result TEXT,
        filePath TEXT,
        synced INTEGER DEFAULT 0,
        scannedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Table contenus
    await db.execute('''
      CREATE TABLE contents(
        id TEXT PRIMARY KEY,
        type TEXT,
        title TEXT,
        artist TEXT,
        description TEXT,
        imageUrl TEXT,
        releaseDate TEXT,
        metadata TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Table favoris
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        userId TEXT,
        contentId TEXT,
        content TEXT,
        synced INTEGER DEFAULT 0,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (contentId) REFERENCES contents (id)
      )
    ''');

    // Table conversations
    await db.execute('''
      CREATE TABLE chats(
        id TEXT PRIMARY KEY,
        userId TEXT,
        messages TEXT,
        synced INTEGER DEFAULT 0,
        lastMessageAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Table recommandations
    await db.execute('''
      CREATE TABLE recommendations(
        id TEXT PRIMARY KEY,
        userId TEXT,
        contentId TEXT,
        score REAL,
        reason TEXT,
        viewed INTEGER DEFAULT 0,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (contentId) REFERENCES contents (id)
      )
    ''');

    // Table queue de synchronisation
    await db.execute('''
      CREATE TABLE sync_queue(
        id TEXT PRIMARY KEY,
        operation TEXT,
        tableName TEXT,
        data TEXT,
        timestamp TEXT,
        retryCount INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS sync_queue');
    await db.execute('DROP TABLE IF EXISTS recommendations');
    await db.execute('DROP TABLE IF EXISTS chats');
    await db.execute('DROP TABLE IF EXISTS favorites');
    await db.execute('DROP TABLE IF EXISTS contents');
    await db.execute('DROP TABLE IF EXISTS scans');
    await db.execute('DROP TABLE IF EXISTS users');
  }
}
