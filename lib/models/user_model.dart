// lib/models/user_model.dart
class UserModel {
  final int userId;
  final String userFullName;
  final String userEmail;
  final String? userImage;
  final String subscription;
  final bool isPremium;
  final bool isActive;
  final Map<String, dynamic>? preferences;
  final DateTime? createdAt;

  const UserModel({
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    this.userImage,
    required this.subscription,
    required this.isPremium,
    required this.isActive,
    this.preferences,
    this.createdAt,
  });

  int get id => userId;
  String get email => userEmail;

  String get displayName =>
      userFullName.isNotEmpty ? userFullName : userEmail.split('@').first;

  String get initials {
    final parts = userFullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return userFullName.isNotEmpty ? userFullName[0].toUpperCase() : '?';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['user_id'] ?? 0,
        userFullName: json['user_full_name'] ?? '',
        userEmail: json['user_email'] ?? '',
        userImage: json['user_image'],
        subscription: json['subscription'] ?? 'Free',
        isPremium: json['is_premium'] ?? false,
        isActive: json['is_active'] ?? true,
        preferences: json['preferences'] is Map
            ? Map<String, dynamic>.from(json['preferences'])
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_full_name': userFullName,
        'user_email': userEmail,
        'user_image': userImage,
        'subscription': subscription,
        'is_premium': isPremium,
        'is_active': isActive,
        'preferences': preferences,
        'created_at': createdAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? userFullName,
    String? userImage,
    String? subscription,
    bool? isPremium,
    Map<String, dynamic>? preferences,
  }) =>
      UserModel(
        userId: userId,
        userFullName: userFullName ?? this.userFullName,
        userEmail: userEmail,
        userImage: userImage ?? this.userImage,
        subscription: subscription ?? this.subscription,
        isPremium: isPremium ?? this.isPremium,
        isActive: isActive,
        preferences: preferences ?? this.preferences,
        createdAt: createdAt,
      );
}
