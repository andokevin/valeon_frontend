// lib/core/database/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:convert';
import 'database_helper.dart';
import 'entities/user_entity.dart';
import 'entities/scan_entity.dart';
import 'entities/favorite_entity.dart';
import 'entities/playlist_entity.dart';
import '../../models/user_model.dart';
import '../../models/scan_model.dart';
import '../../models/content_model.dart';
import '../../models/chat_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ===== UTILITAIRES =====
  String _messagesToJson(List<ChatMessage> messages) {
    return jsonEncode(messages.map((m) => m.toJson()).toList());
  }

  List<ChatMessage> _jsonToMessages(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((item) => ChatMessage.fromJson(item)).toList();
    } catch (e) {
      print('❌ Erreur parsing messages: $e');
      return [];
    }
  }

  // ===== UTILISATEURS =====
  Future<void> upsertUser(UserModel user) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    final entity = UserEntity(
      userId: user.userId,
      userFullName: user.userFullName,
      userEmail: user.userEmail,
      userImage: user.userImage,
      userSubscriptionId: _getSubscriptionId(user.subscription),
      isActive: user.isActive,
      preferences: user.preferences,
      createdAt: user.createdAt ?? now,
      updatedAt: now,
      synced: false,
    );

    await db.insert(
      'users',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  int _getSubscriptionId(String? subscription) {
    switch (subscription) {
      case 'Basic':
        return 2;
      case 'Premium':
        return 3;
      default:
        return 1; // Free
    }
  }

  Future<UserModel?> getUser(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;

    final entity = UserEntity.fromMap(maps.first);

    // Récupérer le nom de l'abonnement
    final subMap = await db.query(
      'subscriptions',
      where: 'subscription_id = ?',
      whereArgs: [entity.userSubscriptionId],
    );

    String subscription = 'Free';
    bool isPremium = false;

    if (subMap.isNotEmpty) {
      subscription = subMap.first['subscription_name'] as String;
      isPremium = (subMap.first['is_premium'] as int) == 1;
    }

    return UserModel(
      userId: entity.userId!,
      userFullName: entity.userFullName,
      userEmail: entity.userEmail,
      userImage: entity.userImage,
      subscription: subscription,
      isPremium: isPremium,
      isActive: entity.isActive,
      preferences: entity.preferences,
      createdAt: entity.createdAt,
    );
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'user_email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return getUser(maps.first['user_id'] as int);
  }

  // ===== SCANS =====
  Future<void> insertScan(ScanModel scan) async {
    final db = await _dbHelper.database;

    final entity = ScanEntity(
      scanId: scan.scanId,
      scanType: scan.scanType.name,
      inputSource: scan.inputSource,
      filePath: scan.filePath,
      fileSize: null, // À remplir si disponible
      processingTime: scan.processingTime,
      status: scan.status.name,
      error: scan.error,
      result: scan.result,
      scanDate: scan.scanDate,
      scanUser: scan.scanUser,
      recognizedContentId: scan.recognizedContentId,
      synced: false,
    );

    await db.insert(
      'scans',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScanModel>> getUserScans(int userId, {int limit = 50}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'scans',
      where: 'scan_user = ?',
      whereArgs: [userId],
      orderBy: 'scan_date DESC',
      limit: limit,
    );

    final scans = <ScanModel>[];
    for (var map in maps) {
      final entity = ScanEntity.fromMap(map);

      // Récupérer le contenu associé si présent
      ContentModel? content;
      if (entity.recognizedContentId != null) {
        final contentMap = await db.query(
          'contents',
          where: 'content_id = ?',
          whereArgs: [entity.recognizedContentId],
        );
        if (contentMap.isNotEmpty) {
          content = ContentModel.fromDbMap(contentMap.first);
        }
      }

      scans.add(ScanModel(
        scanId: entity.scanId!,
        scanType: ScanType.values.firstWhere((e) => e.name == entity.scanType),
        inputSource: entity.inputSource,
        status: ScanStatus.values.firstWhere((e) => e.name == entity.status),
        result: entity.result,
        error: entity.error,
        scanDate: entity.scanDate,
        processingTime: entity.processingTime,
        filePath: entity.filePath,
        scanUser: entity.scanUser,
        recognizedContentId: entity.recognizedContentId,
        content: content,
      ));
    }

    return scans;
  }

  Future<List<ScanEntity>> getUnsyncedScans() async {
    final db = await _dbHelper.database;
    final maps = await db.query('scans', where: 'synced = 0');
    return maps.map((map) => ScanEntity.fromMap(map)).toList();
  }

  Future<void> markScanAsSynced(int scanId) async {
    final db = await _dbHelper.database;
    await db.update(
      'scans',
      {'synced': 1},
      where: 'scan_id = ?',
      whereArgs: [scanId],
    );
  }

  // lib/core/database/database_service.dart

// À AJOUTER dans la section CHAT, après markMessagesAsSynced()

  // ===== CHAT (suite) =====

  /// Supprime un message spécifique d'une conversation
  Future<void> deleteMessage(String messageId) async {
    try {
      final db = await _dbHelper.database;

      // Récupérer tous les chats
      final maps = await db.query('chats');

      for (var map in maps) {
        final chatId = map['id'] as String;
        final userId = map['user_id'] as int;
        final messages = _jsonToMessages(map['messages'] as String?);

        // Vérifier si le message existe dans ce chat
        final messageExists = messages.any((m) => m.id == messageId);

        if (messageExists) {
          // Filtrer pour supprimer le message
          final updatedMessages =
              messages.where((m) => m.id != messageId).toList();

          // Mettre à jour le chat dans la base
          await db.update(
            'chats',
            {
              'messages': _messagesToJson(updatedMessages),
              'synced': 0, // Marquer comme non synchronisé
              'last_message_at': updatedMessages.isNotEmpty
                  ? updatedMessages.last.timestamp.toIso8601String()
                  : DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [chatId],
          );

          print('✅ Message $messageId supprimé du chat $chatId');
          break; // Sortir de la boucle après avoir trouvé et supprimé
        }
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression du message: $e');
      rethrow;
    }
  }

  /// Supprime un message par son ID (version simplifiée si vous connaissez le chat)
  Future<void> deleteMessageFromChat(String chatId, String messageId) async {
    try {
      final db = await _dbHelper.database;

      // Récupérer le chat spécifique
      final maps = await db.query(
        'chats',
        where: 'id = ?',
        whereArgs: [chatId],
      );

      if (maps.isNotEmpty) {
        final messages = _jsonToMessages(maps.first['messages'] as String?);
        final updatedMessages =
            messages.where((m) => m.id != messageId).toList();

        await db.update(
          'chats',
          {
            'messages': _messagesToJson(updatedMessages),
            'synced': 0,
            'last_message_at': updatedMessages.isNotEmpty
                ? updatedMessages.last.timestamp.toIso8601String()
                : DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [chatId],
        );

        print('✅ Message $messageId supprimé du chat $chatId');
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression du message: $e');
      rethrow;
    }
  }

  // ===== FAVORIS =====
  Future<void> insertFavorite(int userId, ContentModel content) async {
    final db = await _dbHelper.database;

    // D'abord, insérer le contenu s'il n'existe pas
    await db.insert(
      'contents',
      content.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    final entity = FavoriteEntity(
      userId: userId,
      contentId: content.contentId,
      notes: null,
      createdAt: DateTime.now(),
      synced: false,
    );

    await db.insert(
      'favorites',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT f.*, c.*
      FROM favorites f
      INNER JOIN contents c ON f.content_id = c.content_id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
    ''', [userId]);

    return maps.map((map) {
      final content = ContentModel.fromDbMap(map);
      return {
        'favorite_id': map['favorite_id'],
        'content_id': map['content_id'],
        'created_at': map['created_at'],
        'synced': map['synced'],
        'content': content.toJson(),
      };
    }).toList();
  }

  Future<void> deleteFavorite(int favoriteId) async {
    final db = await _dbHelper.database;
    await db
        .delete('favorites', where: 'favorite_id = ?', whereArgs: [favoriteId]);
  }

  Future<bool> isFavorite(int userId, int contentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'favorites',
      where: 'user_id = ? AND content_id = ?',
      whereArgs: [userId, contentId],
    );
    return maps.isNotEmpty;
  }

  Future<void> markFavoriteAsSynced(int favoriteId) async {
    final db = await _dbHelper.database;
    await db.update(
      'favorites',
      {'synced': 1},
      where: 'favorite_id = ?',
      whereArgs: [favoriteId],
    );
  }

  // ===== PLAYLISTS =====
  Future<int> createPlaylist(PlaylistEntity playlist) async {
    final db = await _dbHelper.database;
    return await db.insert('playlists', playlist.toMap());
  }

  Future<List<PlaylistEntity>> getUserPlaylists(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'playlists',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PlaylistEntity.fromMap(map)).toList();
  }

  Future<void> addToPlaylist(int playlistId, int contentId) async {
    final db = await _dbHelper.database;
    await db.insert('playlist_contents', {
      'playlist_id': playlistId,
      'content_id': contentId,
      'added_at': DateTime.now().toIso8601String(),
      'position': 0,
    });

    // Mettre à jour le compteur
    await db.execute(
      'UPDATE playlists SET content_count = content_count + 1 WHERE playlist_id = ?',
      [playlistId],
    );
  }

  Future<void> removeFromPlaylist(int playlistId, int contentId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'playlist_contents',
      where: 'playlist_id = ? AND content_id = ?',
      whereArgs: [playlistId, contentId],
    );

    // Mettre à jour le compteur
    await db.execute(
      'UPDATE playlists SET content_count = content_count - 1 WHERE playlist_id = ?',
      [playlistId],
    );
  }

  Future<List<ContentModel>> getPlaylistContents(int playlistId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT c.*
      FROM playlist_contents pc
      INNER JOIN contents c ON pc.content_id = c.content_id
      WHERE pc.playlist_id = ?
      ORDER BY pc.position, pc.added_at
    ''', [playlistId]);

    return maps.map((map) => ContentModel.fromDbMap(map)).toList();
  }

  // ===== CHAT =====
  Future<void> saveChat(ChatConversation chat) async {
    final db = await _dbHelper.database;
    await db.insert(
      'chats',
      {
        'id': chat.id,
        'user_id': int.parse(chat.userId),
        'messages': _messagesToJson(chat.messages),
        'synced': chat.synced ? 1 : 0,
        'last_message_at': chat.lastMessageAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ChatConversation?> getLastChat(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'chats',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_message_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    try {
      final messages = _jsonToMessages(maps.first['messages'] as String?);
      return ChatConversation(
        id: maps.first['id'] as String,
        userId: maps.first['user_id'].toString(),
        messages: messages,
        lastMessageAt: DateTime.parse(maps.first['last_message_at'] as String),
        synced: (maps.first['synced'] as int) == 1,
      );
    } catch (e) {
      print('❌ Erreur parsing last chat: $e');
      return null;
    }
  }

  Future<void> saveMessage(int userId, ChatMessage message) async {
    final chat = await getLastChat(userId) ??
        ChatConversation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId.toString(),
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

  Future<List<ChatMessage>> getUnsyncedMessages(int userId) async {
    final chat = await getLastChat(userId);
    if (chat == null) return [];
    return chat.messages.where((m) => !m.synced).toList();
  }

  Future<void> markMessagesAsSynced(int userId) async {
    final chat = await getLastChat(userId);
    if (chat == null) return;

    final syncedMessages =
        chat.messages.map((m) => m.copyWith(synced: true)).toList();
    final updatedChat = chat.copyWith(
      messages: syncedMessages,
      synced: true,
    );
    await saveChat(updatedChat);
  }

  // ===== QUEUE DE SYNCHRONISATION =====
  Future<void> addToSyncQueue({
    required String operation,
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    final db = await _dbHelper.database;
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
    final db = await _dbHelper.database;
    final maps = await db.query('sync_queue', orderBy: 'timestamp ASC');
    return maps.map((map) {
      final data = jsonDecode(map['data'] as String);
      return {...map, 'data': data};
    }).toList();
  }

  Future<void> removeFromSyncQueue(String id) async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementRetryCount(String id) async {
    final db = await _dbHelper.database;
    await db.execute(
      'UPDATE sync_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }
}
