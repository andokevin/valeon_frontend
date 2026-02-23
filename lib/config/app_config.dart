// lib/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl =
      'http://192.168.175.246:8000/api'; // À modifier selon votre IP
  static const int apiTimeout = 30;
  static const int cacheDurationHours = 24;
  static const int maxOfflineScans = 100;
  static const int syncIntervalMinutes = 15;
  static const int maxSyncRetries = 3;
  static const int pageSize = 20;
  static const String secureStorageKey = 'valeon_secure_v1';
  static const bool enableChatAI = true;
  static const bool enableRecommendations = true;
  static const int maxRecommendations = 20;
}
