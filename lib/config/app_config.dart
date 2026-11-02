// lib/config/app_config.dart
class AppConfig {
  // Surchargeable sans toucher au code :
  // flutter run --dart-define=API_BASE_URL=http://<ip>:8000/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.14.246:8000/api',
  );
  static const int apiTimeout = 120;
  static const int pageSize = 20;
  static const String secureStorageKey = 'valeon_secure_v1';
  static const bool enableChatAI = true;
  static const bool enableRecommendations = true;
  static const int maxRecommendations = 20;
}
