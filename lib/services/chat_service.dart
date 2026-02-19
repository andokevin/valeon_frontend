// lib/services/chat_service.dart
import '../models/chat_model.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../core/network/api_client.dart';

class ChatService {
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiClient _api = ApiClient();

  Future<ChatConversation> getOrCreateChat(String userId) async {
    final existing = await _db.getLastChat(userId);

    if (existing != null) {
      return existing;
    }

    return ChatConversation(
      id: userId,
      userId: userId,
      messages: [
        ChatMessage.assistant(
          'Bonjour ! Je suis votre assistant Valeon. Posez-moi des questions sur des films, musiques ou séries !',
        ),
      ],
      lastMessageAt: DateTime.now(),
    );
  }

  Future<ChatMessage> sendMessage(String userId, String content) async {
    final userMessage = ChatMessage.user(content);

    // Sauvegarder le message utilisateur
    final chat = await getOrCreateChat(userId);
    chat.messages.add(userMessage);
    chat.lastMessageAt = DateTime.now();
    await _db.saveChat(chat);

    // Obtenir la réponse
    String response;

    if (_connectivity.isOnline) {
      response = await _getAIResponse(content, userId);
    } else {
      response = _getOfflineResponse(content);
    }

    final assistantMessage = ChatMessage.assistant(response);
    chat.messages.add(assistantMessage);
    chat.lastMessageAt = DateTime.now();
    await _db.saveChat(chat);

    return assistantMessage;
  }

  Future<String> _getAIResponse(String query, String userId) async {
    try {
      final response = await _api.post(
        '/recommendations/chat',
        data: {
          'query': query,
          'context': {'userId': userId},
        },
      );

      if (response != null && response['recommendations'] != null) {
        final recs = response['recommendations'] as List;
        if (recs.isNotEmpty) {
          var result = '';
          for (var rec in recs) {
            result += '• ${rec['title']}';
            if (rec.containsKey('artist')) {
              result += ' par ${rec['artist']}';
            }
            result += '\n  ${rec['reason']}\n\n';
          }
          return result.trim();
        }
      }
      return "Je n'ai pas trouvé de recommandations pour votre demande.";
    } catch (e) {
      print('❌ API chat error: $e');
      return _getOfflineResponse(query);
    }
  }

  String _getOfflineResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('film') || lowerQuery.contains('movie')) {
      return "En mode hors ligne, voici quelques films populaires :\n"
          "• Inception (Science-fiction)\n"
          "• Interstellar (Science-fiction)\n"
          "• The Dark Knight (Action)";
    } else if (lowerQuery.contains('musique') || lowerQuery.contains('music')) {
      return "Suggestions hors ligne :\n"
          "• Blinding Lights - The Weeknd\n"
          "• Heat Waves - Glass Animals\n"
          "• Sunflower - Post Malone";
    } else {
      return "Connectez-vous à Internet pour des recommandations personnalisées. "
          "En attendant, explorez votre bibliothèque locale.";
    }
  }

  Future<void> clearHistory(String userId) async {
    final chat = await getOrCreateChat(userId);
    chat.messages.clear();
    chat.messages.add(
      ChatMessage.assistant('Historique effacé. Comment puis-je vous aider ?'),
    );
    chat.lastMessageAt = DateTime.now();
    await _db.saveChat(chat);
  }

  // ===== NOUVELLES MÉTHODES POUR LA SYNCHRONISATION =====

  /// Récupère les messages distants depuis le backend
  Future<List<ChatMessage>> getRemoteMessages(String userId) async {
    try {
      if (!_connectivity.isOnline) return [];

      final response = await _api.get('/chat/history/$userId');

      if (response != null && response is List) {
        return response.map((item) => ChatMessage.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération messages distants: $e');
      return [];
    }
  }

  /// Supprime un message distant sur le backend
  Future<bool> deleteRemoteMessage(String userId, String messageId) async {
    try {
      if (!_connectivity.isOnline) return false;

      await _api.delete('/chat/message/$messageId');
      return true;
    } catch (e) {
      print('❌ Erreur suppression message distant: $e');
      return false;
    }
  }

  /// Synchronise un message avec le backend
  Future<ChatMessage?> syncMessage(String userId, ChatMessage message) async {
    try {
      if (!_connectivity.isOnline) return null;

      final response = await _api.post(
        '/chat/messages',
        data: {'userId': userId, 'message': message.toMap()},
      );

      if (response != null) {
        // Marquer le message comme synchronisé localement
        final updatedMessage = ChatMessage(
          id: message.id,
          role: message.role,
          content: message.content,
          timestamp: message.timestamp,
          synced: true,
        );

        // Mettre à jour dans la base locale
        final chat = await getOrCreateChat(userId);
        final index = chat.messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          chat.messages[index] = updatedMessage;
          await _db.saveChat(chat);
        }

        return updatedMessage;
      }
      return null;
    } catch (e) {
      print('❌ Erreur sync message: $e');
      return null;
    }
  }

  /// Récupère la dernière conversation depuis le backend
  Future<ChatConversation?> getRemoteConversation(String userId) async {
    try {
      if (!_connectivity.isOnline) return null;

      final response = await _api.get('/chat/conversation/$userId');

      if (response != null) {
        return ChatConversation(
          id: response['id'] ?? userId,
          userId: userId,
          messages: (response['messages'] as List)
              .map((m) => ChatMessage.fromMap(m))
              .toList(),
          lastMessageAt: DateTime.parse(response['lastMessageAt']),
          synced: true,
        );
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération conversation distante: $e');
      return null;
    }
  }

  /// Marque tous les messages comme lus sur le backend
  Future<bool> markMessagesAsRead(String userId) async {
    try {
      if (!_connectivity.isOnline) return false;

      await _api.post('/chat/mark-read/$userId');
      return true;
    } catch (e) {
      print('❌ Erreur marquage messages comme lus: $e');
      return false;
    }
  }
}
