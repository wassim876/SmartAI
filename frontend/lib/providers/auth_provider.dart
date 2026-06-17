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

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isPremium => _currentUser?.isPremium ?? false;
  List<UserModel> get users => _users;
  String? get errorMessage => _errorMessage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Login and get tokens
      final success = await _authService.login(email, password);

      if (!success) {
        throw Exception('Login failed');
      }

      // Step 2: Fetch user profile
      final user = await _authService.getCurrentUser();

      if (user == null) {
        throw Exception('Could not fetch user profile');
      }

      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
      // Clear tokens without calling the API logout endpoint
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
      // First update the backend
      await _apiService.incrementUsage('message', amount: 1);

      // Then update local state to reflect UI immediately
      _currentUser = _currentUser!.copyWith(
        dailyMessagesUsed: _currentUser!.dailyMessagesUsed + 1,
      );
    } catch (e) {
      print('Failed to sync usage: $e');
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
      print('Auth check failed: $e');
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // lib/providers/auth_provider.dart
// Add this method after fetchUsers() and before logout()

  Future<void> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.createUser(userData);
      // Refresh the user list after creating
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

  // ========== NEW ADMIN USER MANAGEMENT METHODS ==========
// Add these after fetchUsers() and before logout()

  Future<UserModel> updateUser(int userId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateUser(userId, data);

      // Update local user list
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = updatedUser;
      }

      // Update current user if it's the same
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

      // Remove from local list
      _users.removeWhere((u) => u.id == userId);

      // If current user was deleted, logout
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

      // Update local user list
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        final user = _users[userIndex];
        _users[userIndex] = user.copyWith(isActive: !user.isActive);

        // Update current user if it's the same
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

      // Update local user list
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        final user = _users[userIndex];
        _users[userIndex] = user.copyWith(isPremium: !user.isPremium);

        // Update current user if it's the same
        if (_currentUser?.id == userId) {
          _currentUser = _users[userIndex];
        }

        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
