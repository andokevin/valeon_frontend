// lib/core/database/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? photoUrl;
  final String subscription;
  final String? preferences;
  final String? lastSync;
  final String createdAt;

  UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.photoUrl,
    this.subscription = 'Free',
    this.preferences,
    this.lastSync,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'subscription': subscription,
      'preferences': preferences,
      'lastSync': lastSync,
      'createdAt': createdAt,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'],
      email: map['email'],
      fullName: map['fullName'],
      photoUrl: map['photoUrl'],
      subscription: map['subscription'] ?? 'Free',
      preferences: map['preferences'],
      lastSync: map['lastSync'],
      createdAt: map['createdAt'],
    );
  }
}
