import '../models/chat_model.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../core/network/api_client.dart';
import 'package:flutter/foundation.dart';  // debugPrint

class ChatService {
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiClient _api = ApiClient.instance;

  Future<ChatConversation> getOrCreateChat(String userId) async {
    final existing = await _db.getLastChat(userId);
    if (existing != null) return existing;

    return ChatConversation(
      id: userId,
      userId: userId,
      messages: [
        ChatMessage.assistant(
          'Bonjour ! Je suis votre assistant Valeon. Posez-moi des questions sur des films, musiques ou séries ! 🎵🎬',
        ),
      ],
      lastMessageAt: DateTime.now(),
    );
  }

  Future<ChatMessage> sendMessage(String userId, String content) async {
    final userMessage = ChatMessage.user(content);
    final chat = await getOrCreateChat(userId);

    // ✅ copyWith au lieu de muter
    final chatWithUserMsg = chat.copyWith(
      messages: [...chat.messages, userMessage],
      lastMessageAt: DateTime.now(),
    );
    await _db.saveChat(chatWithUserMsg);

    String response;
    if (_connectivity.isOnline) {
      response = await _getAIResponse(content, userId);
    } else {
      response = _getOfflineResponse(content);
    }

    final assistantMessage = ChatMessage.assistant(response);
    final updatedChat = chatWithUserMsg.copyWith(
      messages: [...chatWithUserMsg.messages, assistantMessage],
      lastMessageAt: DateTime.now(),
    );
    await _db.saveChat(updatedChat);

    return assistantMessage;
  }

  Future<String> _getAIResponse(String query, String userId) async {
    try {
      final response = await _api.post(
        '/recommendations/chat',
        data: {'query': query, 'context': {'userId': userId}},
      );
      final data = response.data;
      if (data != null && data['recommendations'] != null) {
        final recs = data['recommendations'] as List<dynamic>? ?? [];
        if (recs.isNotEmpty) {
          var result = 'Voici mes recommandations :\n\n';
          for (final rec in recs.take(5)) {
            result += '🎯 **${rec['title']}**';
            if (rec['artist'] != null) {
              result += ' par *${rec['artist']}*';
            }
            result += '\n${rec['reason'] ?? ''}\n\n';
          }
          return result.trim();
        }
      }
      return "Je n'ai pas trouvé de recommandations précises pour votre demande. Essayez d'être plus spécifique !";
    } catch (e) {
      debugPrint('❌ API chat error: $e');
      return _getOfflineResponse(query);
    }
  }

  String _getOfflineResponse(String query) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.contains('film') || lowerQuery.contains('movie')) {
      return "🔴 **Mode hors ligne**\n\nFilms populaires :\n"
          "• Inception (Sci-fi)\n"
          "• Interstellar (Sci-fi)\n"
          "• The Dark Knight (Action)\n\n"
          "Connectez-vous pour des reco personnalisées !";
    } else if (lowerQuery.contains('musique') || lowerQuery.contains('music')) {
      return "🔴 **Mode hors ligne**\n\nHits populaires :\n"
          "• Blinding Lights - The Weeknd\n"
          "• Heat Waves - Glass Animals\n"
          "• Sunflower - Post Malone\n\n"
          "Connectez-vous pour vos reco !";
    }
    return "🔴 **Hors ligne** — Connectez-vous à Internet pour des recommandations personnalisées.\n\nExplorez votre bibliothèque locale en attendant !";
  }

  Future<void> clearHistory(String userId) async {
    final chat = await getOrCreateChat(userId);
    final welcomeMsg = ChatMessage.assistant(
      'Historique effacé. Comment puis-je vous aider ?',
    );

    final clearedChat = chat.copyWith(
      messages: [welcomeMsg],
      lastMessageAt: DateTime.now(),
    );
    await _db.saveChat(clearedChat);
  }

  // ─── SYNCHRONISATION ────────────────────────────────────────────────────

  Future<List<ChatMessage>> getRemoteMessages(String userId) async {
    try {
      if (!_connectivity.isOnline) return [];
      final response = await _api.get('/chat/history/$userId');
      final data = response.data;
      if (data is List) {
        return data.map((item) => ChatMessage.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Erreur messages distants: $e');
      return [];
    }
  }

  Future<bool> deleteRemoteMessage(String userId, String messageId) async {
    try {
      if (!_connectivity.isOnline) return false;
      await _api.delete('/chat/message/$messageId');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur suppression distante: $e');
      return false;
    }
  }

  Future<ChatMessage?> syncMessage(String userId, ChatMessage message) async {
    try {
      if (!_connectivity.isOnline) return null;
      final response = await _api.post(
        '/chat/messages',
        data: {
          'userId': userId,
          'message': message.toJson(),
        },
      );
      final data = response.data;
      if (data != null) {
        final chat = await getOrCreateChat(userId);
        final index = chat.messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          final syncedMsg = ChatMessage(
            id: message.id,
            role: message.role,
            content: message.content,
            timestamp: message.timestamp,
            synced: true,
          );
          final updatedChat = chat.copyWith(
            messages: [
              for (int i = 0; i < chat.messages.length; i++)
                i == index ? syncedMsg : chat.messages[i],
            ],
          );
          await _db.saveChat(updatedChat);
          return syncedMsg;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erreur sync message: $e');
      return null;
    }
  }

  Future<ChatConversation?> getRemoteConversation(String userId) async {
    try {
      if (!_connectivity.isOnline) return null;
      final response = await _api.get('/chat/conversation/$userId');
      final data = response.data;
      if (data != null) {
        return ChatConversation(
          id: data['id'] ?? userId,
          userId: userId,
          messages: (data['messages'] as List<dynamic>? ?? [])
              .map((m) => ChatMessage.fromJson(m))
              .toList(),
          lastMessageAt: DateTime.parse(data['lastMessageAt']),
          synced: true,
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erreur conversation distante: $e');
      return null;
    }
  }

  Future<bool> markMessagesAsRead(String userId) async {
    try {
      if (!_connectivity.isOnline) return false;
      await _api.post('/chat/mark-read/$userId');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur mark-read: $e');
      return false;
    }
  }
}
