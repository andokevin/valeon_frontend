import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:convert';
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
    final path = join(await getDatabasesPath(), 'valeon.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        user_id     INTEGER PRIMARY KEY,
        full_name   TEXT,
        email       TEXT UNIQUE,
        image       TEXT,
        subscription TEXT,
        is_premium  INTEGER DEFAULT 0,
        preferences TEXT,
        created_at  TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE scans(
        scan_id         TEXT PRIMARY KEY,
        scan_type       TEXT,
        input_source    TEXT,
        status          TEXT,
        result          TEXT,
        error           TEXT,
        file_path       TEXT,
        scan_date       TEXT,
        processing_time REAL,
        synced          INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites(
        id          TEXT PRIMARY KEY,
        user_id     INTEGER,
        content_id  INTEGER,
        content     TEXT,
        synced      INTEGER DEFAULT 0,
        created_at  TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE chats(
        id              TEXT PRIMARY KEY,
        user_id         INTEGER,
        messages        TEXT,
        synced          INTEGER DEFAULT 0,
        last_message_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue(
        id           TEXT PRIMARY KEY,
        operation    TEXT,
        table_name   TEXT,
        data         TEXT,
        timestamp    TEXT,
        retry_count  INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // ─── Helpers JSON ────────────────────────────────────────────────────────

  String _messagesToJson(List<ChatMessage> messages) =>
      jsonEncode(messages.map((m) => m.toMap()).toList());

  List<ChatMessage> _jsonToMessages(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return (jsonDecode(jsonStr) as List)
          .map((item) => ChatMessage.fromMap(item))
          .toList();
    } catch (e) {
      print('❌ Erreur parsing messages: $e');
      return [];
    }
  }

  // ─── UTILISATEURS ────────────────────────────────────────────────────────

  Future<void> upsertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'user_id': user.userId,
        'full_name': user.userFullName,
        'email': user.userEmail,
        'image': user.userImage,
        'subscription': user.subscription,
        'is_premium': user.isPremium ? 1 : 0,
        'preferences': user.preferences != null
            ? jsonEncode(user.preferences)
            : null,
        'created_at': user.createdAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  UserModel _userFromMap(Map<String, dynamic> map) => UserModel(
        userId: map['user_id'] as int,
        userFullName: map['full_name'] ?? '',
        userEmail: map['email'] ?? '',
        userImage: map['image'],
        subscription: map['subscription'] ?? 'Free',
        isPremium: (map['is_premium'] ?? 0) == 1,
        isActive: true,
        preferences: map['preferences'] != null
            ? jsonDecode(map['preferences']) as Map<String, dynamic>
            : null,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'])
            : null,
      );

  // ─── SCANS ───────────────────────────────────────────────────────────────

  Future<void> insertScan(ScanModel scan) async {
    final db = await database;
    await db.insert(
      'scans',
      {
        'scan_id': scan.scanId?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'scan_type': scan.scanType.name,
        'input_source': scan.inputSource,
        'status': scan.status.name,
        'result': scan.result != null ? jsonEncode(scan.result) : null,
        'error': scan.error,
        'file_path': scan.filePath,
        'scan_date': scan.scanDate.toIso8601String(),
        'processing_time': scan.processingTime,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScanModel>> getUserScans(int userId, {int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      'scans',
      orderBy: 'scan_date DESC',
      limit: limit,
    );
    return maps.map(_scanFromMap).toList();
  }

  Future<List<ScanModel>> getUnsyncedScans() async {
    final db = await database;
    final maps = await db.query(
      'scans',
      where: 'synced = 0',
    );
    return maps.map(_scanFromMap).toList();
  }

  Future<void> markScanAsSynced(String scanId) async {
    final db = await database;
    await db.update(
      'scans',
      {'synced': 1},
      where: 'scan_id = ?',
      whereArgs: [scanId],
    );
  }

  ScanModel _scanFromMap(Map<String, dynamic> map) => ScanModel(
        scanId: int.tryParse(map['scan_id']?.toString() ?? ''),
        scanType: ScanType.values.firstWhere(
          (e) => e.name == map['scan_type'],
          orElse: () => ScanType.audio,
        ),
        inputSource: map['input_source'] ?? 'file',
        status: ScanStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => ScanStatus.pending,
        ),
        result: map['result'] != null
            ? jsonDecode(map['result']) as Map<String, dynamic>
            : null,
        error: map['error'],
        filePath: map['file_path'],
        scanDate: DateTime.tryParse(map['scan_date'] ?? '') ?? DateTime.now(),
        processingTime: (map['processing_time'] as num?)?.toDouble(),
      );

  // ─── FAVORIS ─────────────────────────────────────────────────────────────

  Future<void> insertFavorite(int userId, Map<String, dynamic> content) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': userId,
        'content_id': content['contentId'],
        'content': jsonEncode(content),
        'synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) {
      final content = jsonDecode(map['content'] as String);
      return {...map, 'content': content};
    }).toList();
  }

  Future<void> deleteFavorite(String favoriteId) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [favoriteId]);
  }

  // ─── CHAT ────────────────────────────────────────────────────────────────

  Future<void> saveChat(ChatConversation chat) async {
    final db = await database;
    await db.insert(
      'chats',
      {
        'id': chat.id,
        'user_id': chat.userId,
        'messages': _messagesToJson(chat.messages),
        'synced': chat.synced ? 1 : 0,
        'last_message_at': chat.lastMessageAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ChatConversation?> getChat(String chatId) async {
    final db = await database;
    final maps = await db.query(
      'chats',
      where: 'id = ?',
      whereArgs: [chatId],
    );
    if (maps.isEmpty) return null;
    return _chatFromMap(maps.first);
  }

  Future<ChatConversation?> getLastChat(String userId) async {
    final db = await database;
    final maps = await db.query(
      'chats',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_message_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _chatFromMap(maps.first);
  }

  ChatConversation? _chatFromMap(Map<String, dynamic> map) {
    try {
      return ChatConversation(
        id: map['id'] as String,
        userId: map['user_id'].toString(),
        messages: _jsonToMessages(map['messages'] as String?),
        lastMessageAt: DateTime.parse(map['last_message_at'] as String),
        synced: (map['synced'] ?? 0) == 1,
      );
    } catch (e) {
      print('❌ Erreur parsing chat: $e');
      return null;
    }
  }

  // ✅ CORRIGÉ : Utilisation de copyWith pour immutabilité
  Future<void> saveMessage(String userId, ChatMessage message) async {
    final chat = await getLastChat(userId) ??
        ChatConversation(
          id: userId,
          userId: userId,
          messages: [],
          lastMessageAt: DateTime.now(),
        );
    
    final updatedChat = chat.copyWith(
      messages: [...chat.messages, message],
      lastMessageAt: DateTime.now(),
      synced: false,
    );
    
    await saveChat(updatedChat);
  }

  // ✅ CORRIGÉ : Marquer les messages comme synchronisés
  Future<void> markMessagesAsSynced(String userId) async {
    final chat = await getLastChat(userId);
    if (chat == null) return;
    
    // Marquer tous les messages non synchronisés
    final updatedMessages = chat.messages.map((m) => 
      ChatMessage(
        id: m.id,
        role: m.role,
        content: m.content,
        timestamp: m.timestamp,
        synced: true,
      )
    ).toList();
    
    final updatedChat = chat.copyWith(
      messages: updatedMessages,
      synced: true,
    );
    
    await saveChat(updatedChat);
  }

  Future<List<ChatMessage>> getUnsyncedMessages(String userId) async {
    final chat = await getLastChat(userId);
    if (chat == null) return [];
    return chat.messages.where((m) => !m.synced).toList();
  }

  Future<void> deleteMessage(String messageId) async {
    print('⚠️ deleteMessage: non implémenté');
  }

  // ─── SYNC QUEUE ──────────────────────────────────────────────────────────

  Future<void> addToSyncQueue({
    required String operation,
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert('sync_queue', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'operation': operation,
      'table_name': tableName,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    final maps = await db.query('sync_queue', orderBy: 'timestamp ASC');
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
    final maps = await db.query(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final current = maps.first['retry_count'] as int;
      await db.update(
        'sync_queue',
        {'retry_count': current + 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}
