// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../core/database/database_service.dart';
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

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;

  void setConnectivity(ConnectivityProvider connectivity) {
    _connectivity = connectivity;
  }

  Future<void> loadChat(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final conversation = await _service.getOrCreateChat(user.userId);
      _messages = conversation.messages;
      _currentConversationId = conversation.id;

      if (_connectivity.isOnline) {
        await _syncUnsyncedMessages(user);
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur chargement conversation: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content, UserModel user) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      final assistantMessage = await _service.sendMessage(user.userId, content);
      _messages.add(assistantMessage);

      // Sauvegarder localement
      await _db.saveMessage(user.userId, userMessage);
      await _db.saveMessage(user.userId, assistantMessage);

      if (_connectivity.isOnline) {
        await _syncMessages(user);
      }
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';
      _messages.add(
        ChatMessage.assistant(
            'Désolé, une erreur est survenue. Veuillez réessayer.'),
      );
    }

    _isTyping = false;
    notifyListeners();
  }

  Future<void> _syncMessages(UserModel user) async {
    try {
      final unsynced = await _db.getUnsyncedMessages(user.userId);
      for (final message in unsynced) {
        final response = await _service.syncMessage(user.userId, message);
        if (response != null) {
          await _db.markMessagesAsSynced(user.userId);
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur sync messages: $e');
    }
  }

  Future<void> _syncUnsyncedMessages(UserModel user) async {
    try {
      final remoteMessages = await _service.getRemoteMessages(user.userId);
      for (final remoteMsg in remoteMessages) {
        final exists = _messages.any((m) => m.id == remoteMsg.id);
        if (!exists) {
          _messages.add(remoteMsg);
          await _db.saveMessage(user.userId, remoteMsg);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur sync messages distants: $e');
    }
  }

  Future<void> clearHistory(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.clearHistory(user.userId);
      _messages = [
        ChatMessage.assistant(
            'Historique effacé. Comment puis-je vous aider ?'),
      ];
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMessage(String messageId, UserModel user) async {
    try {
      _messages.removeWhere((m) => m.id == messageId);
      await _db.deleteMessage(messageId);
      if (_connectivity.isOnline) {
        await _service.deleteRemoteMessage(user.userId, messageId);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void retryLastMessage(UserModel user) {
    if (_messages.isEmpty) return;

    final lastUserMessage = _messages.lastWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => ChatMessage.user(''),
    );

    if (lastUserMessage.content.isNotEmpty) {
      _messages.removeWhere(
        (m) =>
            m.id == lastUserMessage.id ||
            (_messages.indexOf(m) > _messages.indexOf(lastUserMessage)),
      );
      sendMessage(lastUserMessage.content, user);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
