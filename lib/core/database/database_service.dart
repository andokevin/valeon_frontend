// lib/core/database/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../../models/user_model.dart';
import '../../models/scan_model.dart';
import '../../models/chat_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'valeon.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    // Table favoris
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        userId TEXT,
        contentId TEXT,
        content TEXT,
        synced INTEGER DEFAULT 0,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Table conversations chat
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrations futures
  }

  // ===== UTILISATEURS =====
  Future<void> upsertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String userId) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [userId]);

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // ===== SCANS =====
  Future<void> insertScan(Scan scan) async {
    final db = await database;
    await db.insert(
      'scans',
      scan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Scan>> getUserScans(String userId, {int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      'scans',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'scannedAt DESC',
      limit: limit,
    );

    return maps.map((map) => Scan.fromMap(map)).toList();
  }

  Future<List<Scan>> getUnsyncedScans() async {
    final db = await database;
    final maps = await db.query('scans', where: 'synced = 0');

    return maps.map((map) => Scan.fromMap(map)).toList();
  }

  Future<void> markScanAsSynced(String scanId) async {
    final db = await database;
    await db.update(
      'scans',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [scanId],
    );
  }

  // ===== FAVORIS =====
  Future<void> insertFavorite(
    String userId,
    Map<String, dynamic> content,
  ) async {
    final db = await database;
    await db.insert('favorites', {
      'id': content['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'contentId': content['contentId'],
      'content': content.toString(),
      'synced': 0,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    final db = await database;
    return await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<void> deleteFavorite(String favoriteId) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [favoriteId]);
  }

  // ===== CHAT =====
  Future<void> saveChat(ChatConversation chat) async {
    final db = await database;
    await db.insert(
      'chats',
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ChatConversation?> getLastChat(String userId) async {
    final db = await database;
    final maps = await db.query(
      'chats',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'lastMessageAt DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ChatConversation.fromMap(maps.first);
  }

  // ===== QUEUE DE SYNCHRONISATION =====
  Future<void> addToSyncQueue({
    required String operation,
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert('sync_queue', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'operation': operation,
      'tableName': tableName,
      'data': data.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'timestamp ASC');
  }

  Future<void> removeFromSyncQueue(String id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}
