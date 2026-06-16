import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isPremium => _currentUser?.isPremium ?? false;
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
      await _authService
          .logout(); // Clean up tokens on error but preserve error message
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.register(name, email, password);

      if (!success) {
        throw Exception('Registration failed');
      }

      // Auto-login after signup
      await login(
        email: email,
        password: password,
      );
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

  Future<List<UserModel>> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authService.fetchUsers();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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
