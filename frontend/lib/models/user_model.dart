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

  String get name => displayName.isNotEmpty ? displayName : username;
  String get role => isAdmin ? 'Admin' : 'User';
  String get avatarUrl => photoURL ?? '';

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

  Map<String, dynamic> toFirestore() {
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
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null ? FieldValue.serverTimestamp() : null,
    };
  }

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
}