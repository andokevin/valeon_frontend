// lib/models/auth_model.dart
class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int userId;
  final String userEmail;
  final String userFullName;
  final String subscription;
  final bool isPremium;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.userId,
    required this.userEmail,
    required this.userFullName,
    required this.subscription,
    required this.isPremium,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) => AuthTokenModel(
        accessToken: json['access_token'],
        refreshToken: json['refresh_token'],
        expiresIn: json['expires_in'] ?? 1800,
        userId: json['user_id'],
        userEmail: json['user_email'],
        userFullName: json['user_full_name'],
        subscription: json['subscription'] ?? 'Free',
        isPremium: json['is_premium'] ?? false,
      );
}
