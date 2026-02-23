// lib/core/database/migrations/migration_v1.dart
import 'package:sqflite/sqflite.dart';

class MigrationV1 {
  static Future<void> up(Database db) async {
    // Table subscriptions (correspond au backend)
    await db.execute('''
      CREATE TABLE subscriptions (
        subscription_id INTEGER PRIMARY KEY,
        subscription_name TEXT NOT NULL UNIQUE,
        subscription_price REAL NOT NULL DEFAULT 0,
        subscription_duration INTEGER NOT NULL DEFAULT 0,
        max_scans_per_day INTEGER NOT NULL DEFAULT 5,
        max_scans_per_month INTEGER NOT NULL DEFAULT 50,
        is_premium INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Table users
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_full_name TEXT NOT NULL,
        user_email TEXT NOT NULL UNIQUE,
        user_image TEXT,
        user_subscription_id INTEGER NOT NULL DEFAULT 1,
        is_active INTEGER NOT NULL DEFAULT 1,
        preferences TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_subscription_id) REFERENCES subscriptions(subscription_id)
      )
    ''');

    // Table user_passwords (pour auth offline)
    await db.execute('''
      CREATE TABLE user_passwords (
        password_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        login_attempts INTEGER DEFAULT 0,
        locked_until TEXT,
        last_login TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Table contents
    await db.execute('''
      CREATE TABLE contents (
        content_id INTEGER PRIMARY KEY,
        content_type TEXT NOT NULL,
        content_title TEXT NOT NULL,
        content_original_title TEXT,
        content_description TEXT,
        content_artist TEXT,
        content_director TEXT,
        content_cast TEXT,
        content_image TEXT,
        content_backdrop TEXT,
        content_release_date TEXT,
        content_duration INTEGER,
        content_rating REAL,
        content_url TEXT,
        content_date TEXT NOT NULL,
        spotify_id TEXT,
        tmdb_id INTEGER,
        imdb_id TEXT,
        youtube_id TEXT,
        justwatch_id INTEGER,
        content_metadata TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Table scans
    await db.execute('''
      CREATE TABLE scans (
        scan_id INTEGER PRIMARY KEY AUTOINCREMENT,
        scan_type TEXT NOT NULL,
        input_source TEXT NOT NULL DEFAULT 'file',
        file_path TEXT,
        file_size INTEGER,
        processing_time REAL,
        status TEXT NOT NULL DEFAULT 'pending',
        error TEXT,
        result TEXT,
        scan_date TEXT NOT NULL,
        scan_user INTEGER NOT NULL,
        recognized_content_id INTEGER,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (scan_user) REFERENCES users(user_id),
        FOREIGN KEY (recognized_content_id) REFERENCES contents(content_id)
      )
    ''');

    // Table favorites
    await db.execute('''
      CREATE TABLE favorites (
        favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        content_id INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        UNIQUE(user_id, content_id),
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (content_id) REFERENCES contents(content_id)
      )
    ''');

    // Table playlists
    await db.execute('''
      CREATE TABLE playlists (
        playlist_id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_name TEXT NOT NULL,
        playlist_description TEXT,
        playlist_image TEXT,
        user_id INTEGER NOT NULL,
        is_public INTEGER NOT NULL DEFAULT 0,
        is_collaborative INTEGER NOT NULL DEFAULT 0,
        content_count INTEGER NOT NULL DEFAULT 0,
        playlist_metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Table playlist_contents
    await db.execute('''
      CREATE TABLE playlist_contents (
        playlist_id INTEGER NOT NULL,
        content_id INTEGER NOT NULL,
        added_at TEXT NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (playlist_id, content_id),
        FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
        FOREIGN KEY (content_id) REFERENCES contents(content_id) ON DELETE CASCADE
      )
    ''');

    // Table chats
    await db.execute('''
      CREATE TABLE chats (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        messages TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        last_message_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Table sync_queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        operation TEXT NOT NULL,
        table_name TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Insert default subscription (Free)
    await db.insert('subscriptions', {
      'subscription_id': 1,
      'subscription_name': 'Free',
      'subscription_price': 0.0,
      'subscription_duration': 0,
      'max_scans_per_day': 5,
      'max_scans_per_month': 50,
      'is_premium': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert Basic subscription
    await db.insert('subscriptions', {
      'subscription_id': 2,
      'subscription_name': 'Basic',
      'subscription_price': 4.99,
      'subscription_duration': 30,
      'max_scans_per_day': 20,
      'max_scans_per_month': 200,
      'is_premium': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert Premium subscription
    await db.insert('subscriptions', {
      'subscription_id': 3,
      'subscription_name': 'Premium',
      'subscription_price': 9.99,
      'subscription_duration': 30,
      'max_scans_per_day': 999,
      'max_scans_per_month': 9999,
      'is_premium': 1,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS sync_queue');
    await db.execute('DROP TABLE IF EXISTS playlist_contents');
    await db.execute('DROP TABLE IF EXISTS playlists');
    await db.execute('DROP TABLE IF EXISTS favorites');
    await db.execute('DROP TABLE IF EXISTS scans');
    await db.execute('DROP TABLE IF EXISTS contents');
    await db.execute('DROP TABLE IF EXISTS user_passwords');
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS subscriptions');
    await db.execute('DROP TABLE IF EXISTS chats');
  }
}
