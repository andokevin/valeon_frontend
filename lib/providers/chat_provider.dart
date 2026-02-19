// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart'; // ✅ Correction: import du bon User
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import 'connectivity_provider.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();
  final DatabaseService _db = DatabaseService();
  late ConnectivityProvider _connectivity;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;
  String? _currentConversationId;

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;

  void setConnectivity(ConnectivityProvider connectivity) {
    _connectivity = connectivity;
  }

  // ===== CHARGEMENT DE LA CONVERSATION =====
  // ✅ Renommé de loadConversation à loadChat pour correspondre à l'appel
  Future<void> loadChat(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final conversation = await _service.getOrCreateChat(user.id);
      _messages = conversation.messages;
      _currentConversationId = conversation.id;

      // Marquer les messages non synchronisés
      if (_connectivity.isOnline) {
        await _syncUnsyncedMessages(user);
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Erreur chargement conversation: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Version alternative pour compatibilité (si loadConversation est appelé ailleurs)
  Future<void> loadConversation(User user) => loadChat(user);

  // ===== ENVOI DE MESSAGE =====
  Future<void> sendMessage(String content, User user) async {
    if (content.trim().isEmpty) return;

    // Message utilisateur
    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      final assistantMessage = await _service.sendMessage(user.id, content);
      _messages.add(assistantMessage);

      // Synchroniser si connecté
      if (_connectivity.isOnline) {
        await _syncMessages(user);
      }
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';

      // Message d'erreur
      _messages.add(
        ChatMessage.assistant(
          'Désolé, une erreur est survenue. Veuillez réessayer.',
        ),
      );
    }

    _isTyping = false;
    notifyListeners();
  }

  // ===== SYNC DES MESSAGES =====
  Future<void> _syncMessages(User user) async {
    try {
      final unsynced = await _db.getUnsyncedMessages(user.id);

      for (var message in unsynced) {
        // Envoyer au backend
        final response = await _service.syncMessage(user.id, message);

        if (response != null) {
          await _db.markMessageAsSynced(message.id);
        }
      }
    } catch (e) {
      print('❌ Erreur sync messages: $e');
    }
  }

  Future<void> _syncUnsyncedMessages(User user) async {
    // Récupérer les messages du backend qui manquent localement
    try {
      final remoteMessages = await _service.getRemoteMessages(user.id);

      for (var remoteMsg in remoteMessages) {
        final exists = _messages.any((m) => m.id == remoteMsg.id);
        if (!exists) {
          _messages.add(remoteMsg);
          await _db.saveMessage(user.id, remoteMsg);
        }
      }

      notifyListeners();
    } catch (e) {
      print('❌ Erreur sync messages distants: $e');
    }
  }

  // ===== ACTIONS SUR LA CONVERSATION =====
  Future<void> clearHistory(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.clearHistory(user.id);

      _messages = [
        ChatMessage.assistant(
          'Historique effacé. Comment puis-je vous aider ?',
        ),
      ];
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMessage(String messageId, User user) async {
    try {
      _messages.removeWhere((m) => m.id == messageId);
      await _db.deleteMessage(messageId);

      if (_connectivity.isOnline) {
        await _service.deleteRemoteMessage(user.id, messageId);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // ===== UTILITAIRES =====
  void retryLastMessage(User user) {
    if (_messages.isEmpty) return;

    final lastUserMessage = _messages.lastWhere(
      (m) => m.role == 'user',
      orElse: () => ChatMessage.user(''),
    );

    if (lastUserMessage.content.isNotEmpty) {
      // Supprimer les 2 derniers messages (user + réponse erronée)
      _messages.removeWhere(
        (m) =>
            m.id == lastUserMessage.id ||
            (_messages.indexOf(m) > _messages.indexOf(lastUserMessage)),
      );

      // Renvoyer
      sendMessage(lastUserMessage.content, user);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
