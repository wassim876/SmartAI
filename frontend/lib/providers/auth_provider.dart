// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_data_service.dart';
import '../services/admin_notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SupabaseDataService _dataService = SupabaseDataService();

  UserModel? _currentUser;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  final List<StreamSubscription<dynamic>> _dataSubscriptions = [];

  List<Map<String, dynamic>> _chatHistory = [];
  List<Map<String, dynamic>> _imageAnalyses = [];
  List<Map<String, dynamic>> _speechTranscriptions = [];
  List<Map<String, dynamic>> _activities = [];

  // ==========================================
  // GETTERS
  // ==========================================
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isPremium => _currentUser?.isPremium ?? false;
  List<UserModel> get users => _users;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get chatHistory => _chatHistory;
  List<Map<String, dynamic>> get imageAnalyses => _imageAnalyses;
  List<Map<String, dynamic>> get speechTranscriptions => _speechTranscriptions;
  List<Map<String, dynamic>> get activities => _activities;

  // ==========================================
  // CONSTRUCTOR
  // ==========================================
  AuthProvider() {
    _authService.authStateChanges.listen((state) async {
      final session = state.session;
      if (session != null) {
        try {
          _currentUser = await _dataService.getUserProfile();
          _loadUserData();
        } catch (e) {
          debugPrint('Error loading user: $e');
        }
      } else {
        _currentUser = null;
        _users = [];
        _chatHistory = [];
        _imageAnalyses = [];
        _speechTranscriptions = [];
        _activities = [];
      }
      // Defer notifyListeners until after the current build frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }

  // ==========================================
  // AUTH METHODS
  // ==========================================

  /// Reload just the current user's profile (e.g. after a server-side usage
  /// increment in the nim-chat function) so the UI usage counter stays fresh.
  Future<void> refreshCurrentUser() async {
    if (_authService.currentUser == null) return;
    try {
      _currentUser = await _dataService.getUserProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh user: $e');
    }
  }

  Future<void> resolveUser() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      _currentUser = await _dataService.getUserProfile();
      _loadUserData();
    } catch (e) {
      debugPrint('Error resolving user: $e');
    }
    notifyListeners();
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signUp(
        username: username,
        email: email,
        password: password,
      );
      _currentUser = user;
      try {
        await _dataService.logActivity('signup');
      } catch (_) {}
      try {
        await AdminNotificationService.onNewUser(username, email);
      } catch (_) {}
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      _currentUser = user;
      try {
        await _dataService.logActivity('login');
      } catch (_) {}
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGitHub() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGitHub();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _cancelDataSubscriptions();
    await _authService.signOut();
    _currentUser = null;
    _users = [];
    _chatHistory = [];
    _imageAnalyses = [];
    _speechTranscriptions = [];
    _activities = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  Future<void> resetPasswordWithOtp({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await _authService.resetPasswordWithOtp(
        email: email,
        token: token,
        newPassword: newPassword,
      );
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  Future<void> changePassword(String newPassword) async {
    if (_currentUser == null) throw Exception('Not authenticated');
    try {
      await _authService.changePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    bool clearPhoto = false,
  }) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
        clearPhoto: clearPhoto,
      );
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
      );
      if (clearPhoto) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          username: _currentUser!.username,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          photoURL: null,
          isPremium: _currentUser!.isPremium,
          isActive: _currentUser!.isActive,
          isAdmin: _currentUser!.isAdmin,
          dailyMessagesUsed: _currentUser!.dailyMessagesUsed,
          dailyMessagesLimit: _currentUser!.dailyMessagesLimit,
          createdAt: _currentUser!.createdAt,
          lastLogin: _currentUser!.lastLogin,
        );
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    try {
      await _dataService.updateUserProfile(data);
      _currentUser = _currentUser!.copyWith(
        displayName: data['displayName'] ?? _currentUser!.displayName,
        photoURL: data['photoURL'] ?? _currentUser!.photoURL,
        isPremium: data['isPremium'] ?? _currentUser!.isPremium,
        dailyMessagesLimit:
            data['dailyMessagesLimit'] ?? _currentUser!.dailyMessagesLimit,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // USAGE METHODS
  // ==========================================

  Future<void> incrementDailyMessages() async {
    if (_currentUser == null) return;

    if (_currentUser!.dailyMessagesUsed >= _currentUser!.dailyMessagesLimit) {
      throw Exception('Daily message limit reached');
    }

    try {
      await _dataService.incrementDailyMessages();
      _currentUser = _currentUser!.copyWith(
        dailyMessagesUsed: _currentUser!.dailyMessagesUsed + 1,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to sync usage: $e');
    }
  }

  Future<void> resetDailyUsage() async {
    if (_currentUser == null) return;

    try {
      await _dataService.resetDailyUsage();
      _currentUser = _currentUser!.copyWith(dailyMessagesUsed: 0);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to reset usage: $e');
    }
  }

  // ==========================================
  // DATA LOADING METHODS
  // ==========================================

  // Safe notify — always defers to avoid setState-during-build errors
  void _safeNotify() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_currentUser != null) {
        notifyListeners();
      }
    });
  }

  void _loadUserData() {
    if (_currentUser == null) return;

    _cancelDataSubscriptions();

    _dataSubscriptions.add(
      _dataService.getChatHistory().listen((rows) {
        _chatHistory = rows;
        _safeNotify();
      }),
    );

    _dataSubscriptions.add(
      _dataService.getImageAnalyses().listen((rows) {
        _imageAnalyses = rows;
        _safeNotify();
      }),
    );

    _dataSubscriptions.add(
      _dataService.getSpeechTranscriptions().listen((rows) {
        _speechTranscriptions = rows;
        _safeNotify();
      }),
    );

    _dataSubscriptions.add(
      _dataService.getUserActivities().listen((rows) {
        _activities = rows;
        _safeNotify();
      }),
    );
  }

  void _cancelDataSubscriptions() {
    for (final sub in _dataSubscriptions) {
      sub.cancel();
    }
    _dataSubscriptions.clear();
  }

  Future<void> fetchAllUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _loadUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // ADMIN METHODS
  // ==========================================

  Future<List<UserModel>> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final users = await _dataService.getAllUsers();
      _users = users;
      return _users;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.adminCreateUser(
        username: userData['username'],
        email: userData['email'],
        password: userData['password'],
        isAdmin: userData['role'] == 'Admin',
        isPremium: userData['isPremium'] ?? false,
      );
      await fetchUsers();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel> updateUser(String userId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dataService.adminUpdateUser(userId, data);
      await fetchUsers();
      return _users.firstWhere((u) => u.uid == userId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dataService.adminDeleteUser(userId);
      _users.removeWhere((u) => u.uid == userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleUserStatus(String userId) async {
    try {
      final user = _users.firstWhere((u) => u.uid == userId);
      await _dataService.adminUpdateUser(userId, {
        'isActive': !user.isActive,
      });
      await fetchUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleUserPremium(String userId) async {
    try {
      final user = _users.firstWhere((u) => u.uid == userId);
      await _dataService.adminUpdateUser(userId, {
        'isPremium': !user.isPremium,
      });
      await fetchUsers();
    } catch (e) {
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
