// lib/core/database/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:convert'; // ✅ AJOUTER CET IMPORT
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
        scannedAt TEXT
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
        createdAt TEXT
      )
    ''');

    // ✅ Table chats - AVEC JSON POUR LES MESSAGES
    await db.execute('''
      CREATE TABLE chats(
        id TEXT PRIMARY KEY,
        userId TEXT,
        messages TEXT,  -- Stocké en JSON
        synced INTEGER DEFAULT 0,
        lastMessageAt TEXT
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

  // ===== UTILITAIRES POUR LES MESSAGES =====
  String _messagesToJson(List<ChatMessage> messages) {
    return jsonEncode(messages.map((m) => m.toMap()).toList());
  }

  List<ChatMessage> _jsonToMessages(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((item) => ChatMessage.fromMap(item)).toList();
    } catch (e) {
      print('❌ Erreur parsing messages: $e');
      return [];
    }
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
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'contentId': content['contentId'],
      'content': jsonEncode(content), // ✅ Stocker en JSON
      'synced': 0,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    // ✅ Parser le contenu JSON
    return maps.map((map) {
      final content = jsonDecode(map['content'] as String);
      return {...map, 'content': content};
    }).toList();
  }

  Future<void> deleteFavorite(String favoriteId) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [favoriteId]);
  }

  // ===== CHAT =====
  Future<void> saveChat(ChatConversation chat) async {
    final db = await database;
    await db.insert('chats', {
      'id': chat.id,
      'userId': chat.userId,
      'messages': _messagesToJson(chat.messages), // ✅ Stocker en JSON
      'synced': chat.synced ? 1 : 0,
      'lastMessageAt': chat.lastMessageAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ChatConversation?> getChat(String chatId) async {
    final db = await database;
    final maps = await db.query('chats', where: 'id = ?', whereArgs: [chatId]);

    if (maps.isEmpty) return null;

    try {
      final messages = _jsonToMessages(
        maps.first['messages'] as String?,
      ); // ✅ Parser JSON

      return ChatConversation(
        id: maps.first['id'] as String,
        userId: maps.first['userId'] as String,
        messages: messages,
        lastMessageAt: DateTime.parse(maps.first['lastMessageAt'] as String),
        synced: maps.first['synced'] == 1,
      );
    } catch (e) {
      print('❌ Erreur parsing chat: $e');
      return null;
    }
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

    try {
      final messages = _jsonToMessages(
        maps.first['messages'] as String?,
      ); // ✅ Parser JSON

      return ChatConversation(
        id: maps.first['id'] as String,
        userId: maps.first['userId'] as String,
        messages: messages,
        lastMessageAt: DateTime.parse(maps.first['lastMessageAt'] as String),
        synced: maps.first['synced'] == 1,
      );
    } catch (e) {
      print('❌ Erreur parsing last chat: $e');
      return null;
    }
  }

  Future<void> saveMessage(String userId, ChatMessage message) async {
    final chat =
        await getLastChat(userId) ??
        ChatConversation(
          id: userId,
          userId: userId,
          messages: [],
          lastMessageAt: DateTime.now(),
        );

    chat.messages.add(message);
    chat.lastMessageAt = DateTime.now();
    chat.synced = false;

    await saveChat(chat);
  }

  Future<List<ChatMessage>> getUnsyncedMessages(String userId) async {
    final chat = await getLastChat(userId);
    if (chat == null) return [];

    return chat.messages.where((m) => !m.synced).toList();
  }

  Future<void> markMessageAsSynced(String messageId) async {
    // Complexe à implémenter proprement
    // Pour l'instant, on marque tout le dernier chat comme synchronisé
    final db = await database;
    await db.update(
      'chats',
      {'synced': 1},
      where: 'id LIKE ?',
      whereArgs: ['%'],
    );
  }

  Future<void> deleteMessage(String messageId) async {
    // Pour supprimer un message, il faudrait parcourir tous les chats
    print('⚠️ deleteMessage non implémenté - à faire si nécessaire');
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
      'data': jsonEncode(data), // ✅ Stocker en JSON
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    final maps = await db.query('sync_queue', orderBy: 'timestamp ASC');

    // ✅ Parser les données JSON
    return maps.map((map) {
      final data = jsonDecode(map['data'] as String);
      return {...map, 'data': data};
    }).toList();
  }

  Future<void> removeFromSyncQueue(String id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementRetryCount(String id) async {
    final db = await database;
    final maps = await db.query('sync_queue', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final currentRetry = maps.first['retryCount'] as int;
      await db.update(
        'sync_queue',
        {'retryCount': currentRetry + 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // lib/core/database/database_service.dart (AJOUT)
  Future<void> markFavoriteAsSynced(String favoriteId) async {
    final db = await database;
    await db.update(
      'favorites',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [favoriteId],
    );
  }
}
