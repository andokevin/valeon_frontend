// lib/config/app_config.dart
class AppConfig {
  // API
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const int apiTimeout = 30; // secondes

  // Cache
  static const int cacheDurationHours = 24;
  static const int maxOfflineScans = 100;

  // Sync
  static const int syncIntervalMinutes = 15;
  static const int maxSyncRetries = 3;

  // Pagination
  static const int pageSize = 20;

  // Security
  static const String secureStorageKey = 'valeon_secure_v1';

  // Features
  static const bool enableChatAI = true;
  static const bool enableRecommendations = true;
  static const int maxRecommendations = 20;
}
