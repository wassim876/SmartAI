// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _chatHistory = [];
  List<Map<String, dynamic>> _imageAnalyses = [];
  List<Map<String, dynamic>> _speechTranscriptions = [];
  List<Map<String, dynamic>> _translations = [];
  List<Map<String, dynamic>> _activities = [];

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
  List<Map<String, dynamic>> get translations => _translations;
  List<Map<String, dynamic>> get activities => _activities;

  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          _currentUser = await _firestoreService.getUserProfile();
          _loadUserData();
          notifyListeners();
        } catch (e) {
          debugPrint('Error loading user: $e');
        }
      } else {
        _currentUser = null;
        _users = [];
        _chatHistory = [];
        _imageAnalyses = [];
        _speechTranscriptions = [];
        _translations = [];
        _activities = [];
        notifyListeners();
      }
    });
  }

  // ==========================================
  // AUTH METHODS
  // ==========================================

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
      await _firestoreService.logActivity('signup');
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
      await _firestoreService.logActivity('login');
      _loadUserData();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      _currentUser = user;
      if (user != null) {
        await _firestoreService.logActivity('google_login');
        _loadUserData();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGitHub() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGitHub();
      _currentUser = user;
      if (user != null) {
        await _firestoreService.logActivity('github_login');
        _loadUserData();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _users = [];
    _chatHistory = [];
    _imageAnalyses = [];
    _speechTranscriptions = [];
    _translations = [];
    _activities = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    try {
      await _firestoreService.updateUserProfile(data);
      _currentUser = _currentUser!.copyWith(
        displayName: data['displayName'],
        isPremium: data['isPremium'],
        dailyMessagesLimit: data['dailyMessagesLimit'],
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
      await _firestoreService.incrementDailyMessages();
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
      await _firestoreService.resetDailyUsage();
      _currentUser = _currentUser!.copyWith(dailyMessagesUsed: 0);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to reset usage: $e');
    }
  }

  // ==========================================
  // DATA LOADING METHODS
  // ==========================================

  void _loadUserData() {
    if (_currentUser == null) return;

    _firestoreService.getChatHistory().listen((snapshot) {
      _chatHistory = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      notifyListeners();
    });

    _firestoreService.getImageAnalyses().listen((snapshot) {
      _imageAnalyses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      notifyListeners();
    });

    _firestoreService.getSpeechTranscriptions().listen((snapshot) {
      _speechTranscriptions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      notifyListeners();
    });

    _firestoreService.getTranslations().listen((snapshot) {
      _translations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      notifyListeners();
    });

    _firestoreService.getUserActivities().listen((snapshot) {
      _activities = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      notifyListeners();
    });
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
      final users = await _firestoreService.getAllUsers();
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
      final user = await _authService.signUp(
        username: userData['username'],
        email: userData['email'],
        password: userData['password'],
      );
      if (user != null) {
        await _firestoreService.adminUpdateUser(user.uid, {
          'isAdmin': userData['role'] == 'Admin',
          'isPremium': userData['isPremium'] ?? false,
        });
        await fetchUsers();
      }
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
      await _firestoreService.adminUpdateUser(userId, data);
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
      await _firestoreService.adminDeleteUser(userId);
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
      await _firestoreService.adminUpdateUser(userId, {
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
      await _firestoreService.adminUpdateUser(userId, {
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