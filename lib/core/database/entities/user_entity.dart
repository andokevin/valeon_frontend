// lib/core/database/entities/user_entity.dart
import 'dart:convert';

class UserEntity {
  final int? userId;
  final String userFullName;
  final String userEmail;
  final String? userImage;
  final int userSubscriptionId;
  final bool isActive;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  UserEntity({
    this.userId,
    required this.userFullName,
    required this.userEmail,
    this.userImage,
    this.userSubscriptionId = 1,
    this.isActive = true,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_full_name': userFullName,
      'user_email': userEmail,
      'user_image': userImage,
      'user_subscription_id': userSubscriptionId,
      'is_active': isActive ? 1 : 0,
      'preferences': preferences != null ? jsonEncode(preferences) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      userId: map['user_id'],
      userFullName: map['user_full_name'],
      userEmail: map['user_email'],
      userImage: map['user_image'],
      userSubscriptionId: map['user_subscription_id'] ?? 1,
      isActive: map['is_active'] == 1,
      preferences:
          map['preferences'] != null ? jsonDecode(map['preferences']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      synced: map['synced'] == 1,
    );
  }
}
