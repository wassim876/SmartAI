// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Data from MongoDB
  List<Map<String, dynamic>> _chatHistory = [];
  List<Map<String, dynamic>> _imageAnalyses = [];
  List<Map<String, dynamic>> _speechTranscriptions = [];
  List<Map<String, dynamic>> _translations = [];
  List<Map<String, dynamic>> _activities = [];

  // Getters
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

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);

      if (!success) {
        throw Exception('Login failed');
      }

      final user = await _authService.getCurrentUser();

      if (user == null) {
        throw Exception('Could not fetch user profile');
      }

      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
      try {
        await _authService.logout();
      } catch (_) {}
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.register(username, email, password);
      if (!success) throw Exception('Registration failed');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> incrementDailyMessages() async {
    if (_currentUser == null) return;

    if (_currentUser!.dailyMessagesUsed >= _currentUser!.dailyMessagesLimit) {
      throw Exception('Daily message limit reached');
    }

    try {
      await _apiService.incrementUsage('message', amount: 1);

      _currentUser = _currentUser!.copyWith(
        dailyMessagesUsed: _currentUser!.dailyMessagesUsed + 1,
      );
    } catch (e) {
      debugPrint('Failed to sync usage: $e');
    }

    notifyListeners();
  }

  Future<void> resetDailyUsage() async {
    if (_currentUser == null) return;

    final now = DateTime.now();
    final lastReset = _currentUser!.lastResetDate;

    if (now.day != lastReset.day ||
        now.month != lastReset.month ||
        now.year != lastReset.year) {
      _currentUser = _currentUser!.copyWith(
        dailyMessagesUsed: 0,
        translationCharsUsed: 0,
        lastResetDate: now,
      );

      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isValid = await _authService.isTokenValid();

      if (isValid) {
        final user = await _authService.getCurrentUser();
        if (user == null) {
          throw Exception('Session expired');
        }
        _currentUser = user;
        await resetDailyUsage();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Auth check failed: $e');
      await logout();
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
      await _authService.createUser(userData);
      await fetchUsers();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final users = await _authService.fetchUsers();
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

  Future<UserModel> updateUser(int userId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateUser(userId, data);

      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = updatedUser;
      }

      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
      }

      notifyListeners();
      return updatedUser;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.deleteUser(userId);

      _users.removeWhere((u) => u.id == userId);

      if (_currentUser?.id == userId) {
        await logout();
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

  Future<void> toggleUserStatus(int userId) async {
    try {
      await _authService.toggleUserStatus(userId);

      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        final user = _users[userIndex];
        _users[userIndex] = user.copyWith(isActive: !user.isActive);

        if (_currentUser?.id == userId) {
          _currentUser = _users[userIndex];
        }

        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleUserPremium(int userId) async {
    try {
      await _authService.toggleUserPremium(userId);

      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        final user = _users[userIndex];
        _users[userIndex] = user.copyWith(isPremium: !user.isPremium);

        if (_currentUser?.id == userId) {
          _currentUser = _users[userIndex];
        }

        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // MONGODB DATA FETCHING METHODS
  // ============================================

  Future<void> fetchAllUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchChatHistory(),
        fetchImageAnalyses(),
        fetchSpeechTranscriptions(),
        fetchTranslations(),
        fetchActivities(),
      ]);
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChatHistory() async {
    try {
      _chatHistory = await _apiService.getChatHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching chat history: $e');
      _chatHistory = [];
    }
  }

  Future<void> fetchImageAnalyses() async {
    try {
      _imageAnalyses = await _apiService.getImageAnalyses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching image analyses: $e');
      _imageAnalyses = [];
    }
  }

  Future<void> fetchSpeechTranscriptions() async {
    try {
      _speechTranscriptions = await _apiService.getSpeechTranscriptions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching speech transcriptions: $e');
      _speechTranscriptions = [];
    }
  }

  Future<void> fetchTranslations() async {
    try {
      _translations = await _apiService.getTranslations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching translations: $e');
      _translations = [];
    }
  }

  Future<void> fetchActivities() async {
    try {
      _activities = await _apiService.getUserActivities();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      _activities = [];
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    _chatHistory = [];
    _imageAnalyses = [];
    _speechTranscriptions = [];
    _translations = [];
    _activities = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}