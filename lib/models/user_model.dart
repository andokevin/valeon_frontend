// lib/models/user_model.dart
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? photoUrl;
  final String? subscription;
  final Map<String, dynamic>? preferences;
  final DateTime? lastSync;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.photoUrl,
    this.subscription = 'Free',
    this.preferences,
    this.lastSync,
    required this.createdAt,
  });

  factory User.fromFirebase(User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      fullName: map['fullName'],
      photoUrl: map['photoUrl'],
      subscription: map['subscription'] ?? 'Free',
      preferences: map['preferences'] != null
          ? Map<String, dynamic>.from(map['preferences'])
          : null,
      lastSync: map['lastSync'] != null
          ? DateTime.parse(map['lastSync'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'subscription': subscription,
      'preferences': preferences,
      'lastSync': lastSync?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get displayName => fullName ?? email.split('@').first;
  bool get isPremium => subscription == 'Premium' || subscription == 'Pro';
}
