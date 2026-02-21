import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _db;

  DatabaseHelper._();
  static DatabaseHelper get instance => _instance ??= DatabaseHelper._();

  Future<Database> get database async => _db ??= await _initDb();

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, AppConstants.dbName),
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscriptions (
        subscription_id   INTEGER PRIMARY KEY,
        subscription_name TEXT NOT NULL UNIQUE,
        subscription_price REAL NOT NULL DEFAULT 0,
        subscription_duration INTEGER NOT NULL DEFAULT 0,
        max_scans_per_day INTEGER NOT NULL DEFAULT 5,
        max_scans_per_month INTEGER NOT NULL DEFAULT 50,
        is_premium INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        user_id              INTEGER PRIMARY KEY,
        user_full_name       TEXT NOT NULL,
        user_email           TEXT NOT NULL UNIQUE,
        user_image           TEXT,
        user_subscription_id INTEGER NOT NULL DEFAULT 1,
        is_active            INTEGER NOT NULL DEFAULT 1,
        preferences          TEXT,
        created_at           TEXT NOT NULL,
        updated_at           TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS contents (
        content_id            INTEGER PRIMARY KEY,
        content_type          TEXT NOT NULL,
        content_title         TEXT NOT NULL,
        content_original_title TEXT,
        content_description   TEXT,
        content_artist        TEXT,
        content_director      TEXT,
        content_cast          TEXT,
        content_image         TEXT,
        content_backdrop      TEXT,
        content_release_date  TEXT,
        content_duration      INTEGER,
        content_rating        REAL,
        content_url           TEXT,
        content_date          TEXT NOT NULL,
        spotify_id            TEXT,
        tmdb_id               INTEGER,
        imdb_id               TEXT,
        filepath              TEXT,
        youtube_id            TEXT,
        justwatch_id          INTEGER,
        content_metadata      TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlists (
        playlist_id          INTEGER PRIMARY KEY,
        playlist_name        TEXT NOT NULL,
        playlist_description TEXT,
        playlist_image       TEXT,
        user_id              INTEGER NOT NULL,
        is_public            INTEGER NOT NULL DEFAULT 0,
        content_count        INTEGER NOT NULL DEFAULT 0,
        created_at           TEXT NOT NULL,
        updated_at           TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlist_contents (
        playlist_id INTEGER NOT NULL,
        content_id  INTEGER NOT NULL,
        added_at    TEXT NOT NULL,
        position    INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (playlist_id, content_id),
        FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
        FOREIGN KEY (content_id)  REFERENCES contents(content_id)  ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS scans (
        scan_id               INTEGER PRIMARY KEY,
        scan_type             TEXT NOT NULL,
        input_source          TEXT NOT NULL DEFAULT 'file',
        file_path             TEXT,
        processing_time       REAL,
        status                TEXT NOT NULL DEFAULT 'pending',
        error                 TEXT,
        result                TEXT,
        scan_date             TEXT NOT NULL,
        scan_user             INTEGER NOT NULL,
        recognized_content_id INTEGER,
        synced                INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (scan_user)             REFERENCES users(user_id),
        FOREIGN KEY (recognized_content_id) REFERENCES contents(content_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id     INTEGER NOT NULL,
        content_id  INTEGER NOT NULL,
        notes       TEXT,
        created_at  TEXT NOT NULL,
        synced      INTEGER NOT NULL DEFAULT 0,
        UNIQUE (user_id, content_id),
        FOREIGN KEY (user_id)    REFERENCES users(user_id),
        FOREIGN KEY (content_id) REFERENCES contents(content_id)
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_scans_user    ON scans(scan_user);
      ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
      ''');
  }
}
