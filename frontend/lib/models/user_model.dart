// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// Create UserModel from Firebase Auth User
  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      username: user.displayName ?? user.email?.split('@').first ?? 'user',
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoURL: user.photoURL,
      isPremium: false,
      isActive: true,
      isAdmin: false,
      dailyMessagesUsed: 0,
      dailyMessagesLimit: 50,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  /// Create UserModel from Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      isPremium: data['isPremium'] ?? false,
      isActive: data['isActive'] ?? true,
      isAdmin: data['isAdmin'] ?? false,
      dailyMessagesUsed: data['dailyMessagesUsed'] ?? 0,
      dailyMessagesLimit: data['dailyMessagesLimit'] ?? 50,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  // ==========================================
  // TO MAP METHODS
  // ==========================================

  /// For creating a new user in Firestore
  Map<String, dynamic> toFirestoreForCreate() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isPremium': isPremium,
      'isActive': isActive,
      'isAdmin': isAdmin,
      'dailyMessagesUsed': dailyMessagesUsed,
      'dailyMessagesLimit': dailyMessagesLimit,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    };
  }

  /// For updating an existing user in Firestore
  Map<String, dynamic> toFirestoreForUpdate() {
    return {
      'username': username,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isPremium': isPremium,
      'isActive': isActive,
      'isAdmin': isAdmin,
      'dailyMessagesUsed': dailyMessagesUsed,
      'dailyMessagesLimit': dailyMessagesLimit,
      'lastLogin': FieldValue.serverTimestamp(),
    };
  }

  /// For use when you need a complete map (use with caution)
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isPremium': isPremium,
      'isActive': isActive,
      'isAdmin': isAdmin,
      'dailyMessagesUsed': dailyMessagesUsed,
      'dailyMessagesLimit': dailyMessagesLimit,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
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
