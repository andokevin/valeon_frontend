// lib/config/app_constants.dart
class AppConstants {
  static const String appName = 'Valeon';
  static const String appTagline = 'Know what you see, hear, and watch';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const int dbVersion = 3;
  static const String dbName = 'valeon.db';

  // Tables names
  static const String tableUsers = 'users';
  static const String tableScans = 'scans';
  static const String tableContents = 'contents';
  static const String tableFavorites = 'favorites';
  static const String tablePlaylists = 'playlists';
  static const String tablePlaylistContents = 'playlist_contents';
  static const String tableChats = 'chats';
  static const String tableSyncQueue = 'sync_queue';
}
