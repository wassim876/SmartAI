// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool isPremium;
  final bool isActive;
  final bool isAdmin;
  final int dailyMessagesUsed;
  final int dailyMessagesLimit;
  final DateTime createdAt;
  final DateTime? lastLogin;

  // ==========================================
  // GETTERS
  // ==========================================
  String get name => displayName.isNotEmpty ? displayName : username;
  String get role => isAdmin ? 'Admin' : 'User';
  String get avatarUrl => photoURL ?? '';
  bool get isPro => isPremium;

  // ==========================================
  // CONSTRUCTOR
  // ==========================================
  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.isPremium,
    required this.isActive,
    required this.isAdmin,
    required this.dailyMessagesUsed,
    required this.dailyMessagesLimit,
    required this.createdAt,
    this.lastLogin,
  });

  // ==========================================
  // FACTORY CONSTRUCTORS
  // ==========================================

  /// Create a UserModel from a Supabase `profiles` row (snake_case columns).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['id'] as String,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      displayName: map['display_name'] ?? '',
      photoURL: map['photo_url'],
      isPremium: map['is_premium'] ?? false,
      isActive: map['is_active'] ?? true,
      isAdmin: map['is_admin'] ?? false,
      dailyMessagesUsed: map['daily_messages_used'] ?? 0,
      dailyMessagesLimit: map['daily_messages_limit'] ?? 50,
      createdAt: _parseDate(map['created_at']) ?? DateTime.now(),
      lastLogin: _parseDate(map['last_login']),
    );
  }

  // ==========================================
  // TO MAP
  // ==========================================

  /// Column map for `profiles` inserts/updates. Server-managed timestamps
  /// (`created_at`, `last_login`) are intentionally omitted.
  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'username': username,
      'email': email,
      'display_name': displayName,
      'photo_url': photoURL,
      'is_premium': isPremium,
      'is_active': isActive,
      'is_admin': isAdmin,
      'daily_messages_used': dailyMessagesUsed,
      'daily_messages_limit': dailyMessagesLimit,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  // ==========================================
  // COPY WITH
  // ==========================================
  UserModel copyWith({
    String? username,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isPremium,
    bool? isActive,
    bool? isAdmin,
    int? dailyMessagesUsed,
    int? dailyMessagesLimit,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isPremium: isPremium ?? this.isPremium,
      isActive: isActive ?? this.isActive,
      isAdmin: isAdmin ?? this.isAdmin,
      dailyMessagesUsed: dailyMessagesUsed ?? this.dailyMessagesUsed,
      dailyMessagesLimit: dailyMessagesLimit ?? this.dailyMessagesLimit,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Check if user has reached daily message limit
  bool get hasReachedDailyLimit {
    return dailyMessagesUsed >= dailyMessagesLimit;
  }

  /// Get remaining messages for today
  int get remainingMessages {
    return dailyMessagesLimit - dailyMessagesUsed;
  }

  /// Get user's display name or fallback
  String get displayNameOrUsername {
    return displayName.isNotEmpty ? displayName : username;
  }

  /// Check if user is active
  bool get isActiveUser => isActive;

  /// Check if user is premium
  bool get isPremiumUser => isPremium;

  /// Check if user is admin
  bool get isAdminUser => isAdmin;
}
