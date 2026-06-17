// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService() {
    _dio.options.baseUrl = '${ApiConfig.baseUrl}/api';
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/token/', data: {
        'username': email, // backend accepts email OR username
        'password': password,
      });

      if (response.statusCode == 200) {
        await _storage.write(
            key: 'access_token', value: response.data['access']);
        await _storage.write(
            key: 'refresh_token', value: response.data['refresh']);
        return true;
      }
      return false;
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Login failed. Please check your credentials.';
      if (data is Map) {
        message = data['detail'] ?? data['non_field_errors']?.first ?? message;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Connection error. Make sure the server is running.');
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await _dio.post('/register/', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Registration failed.';
      if (data is Map) {
        final firstError = data.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        } else if (firstError is String) {
          message = firstError;
        }
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Connection error. Make sure the server is running.');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return null;

      final response = await _dio.get(
        '/user/profile/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '/users/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('Fetch users response status: ${response.statusCode}');
      print('Fetch users response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both response formats
        List<dynamic> usersData;

        // Check if response has the {success, data} format
        if (data is Map<String, dynamic> &&
            data['success'] == true &&
            data['data'] != null) {
          usersData = data['data'] as List<dynamic>;
        }
        // Check if response is a raw list
        else if (data is List<dynamic>) {
          usersData = data;
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        return usersData.map((json) {
          // Convert to UserModel with default values for missing fields
          return UserModel(
            id: json['id'] ?? 0,
            username: json['username'] ?? '',
            email: json['email'] ?? '',
            name: json['name'] ?? json['username'] ?? '',
            firstName: json['first_name'] ?? '',
            lastName: json['last_name'] ?? '',
            isActive: json['is_active'] ?? false,
            dateJoined: json['date_joined'] != null
                ? DateTime.parse(json['date_joined'])
                : DateTime.now(),
            isAdmin:
                (json['is_staff'] ?? false) || (json['is_superuser'] ?? false),
            isPremium: json['is_premium'] ?? false,
            dailyMessagesUsed: json['daily_messages_used'] ?? 0,
            dailyMessagesLimit: json['daily_messages_limit'] ?? 50,
            monthlySpeechMinutesUsed: json['monthly_speech_minutes_used'] ?? 0,
            monthlySpeechMinutesLimit:
                json['monthly_speech_minutes_limit'] ?? 10,
            translationCharsUsed: json['translation_chars_used'] ?? 0,
            translationCharsLimit: json['translation_chars_limit'] ?? 1000,
            lastResetDate: json['last_reset_date'] != null
                ? DateTime.parse(json['last_reset_date'])
                : DateTime.now(),
            avatarUrl: json['profile_picture'],
          );
        }).toList();
      }
      throw Exception('Failed to fetch users: ${response.statusCode}');
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      }
      rethrow;
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  // ========== NEW ADMIN USER MANAGEMENT METHODS ==========
// Add these after fetchUsers() and before isTokenValid()

  Future<UserModel> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.put(
        '/users/$userId/',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        if (result['success'] == true) {
          return UserModel.fromJson(result['data']);
        } else {
          throw Exception(result['message'] ?? 'Failed to update user');
        }
      }
      throw Exception('Failed to update user: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.delete(
        '/users/$userId/delete/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Failed to delete user');
        }
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleUserStatus(int userId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.post(
        '/users/$userId/toggle-status/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Failed to toggle status');
        }
      } else {
        throw Exception('Failed to toggle status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleUserPremium(int userId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.post(
        '/users/$userId/toggle-premium/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Failed to toggle premium');
        }
      } else {
        throw Exception('Failed to toggle premium: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isTokenValid() async {
    try {
      final token = await _storage.read(key: 'access_token');
      return token != null;
    } catch (e) {
      return false;
    }
  }

  // lib/services/auth_service.dart
// Add this method after fetchUsers() and before isTokenValid()

  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.post(
        '/register/', // Using existing register endpoint
        data: {
          'username':
              userData['username'] ?? userData['email'].split('@').first,
          'email': userData['email'],
          'first_name': userData['first_name'] ?? '',
          'password': userData['password'],
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');

    if (accessToken != null && refreshToken != null) {
      try {
        await _dio.post(
          '/logout/',
          data: {'refresh': refreshToken},
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
      } catch (e) {
        // Continue to clear local storage even if API call fails
      }
    }
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> resetPassword(String email) async {
    try {
      await _dio.post('/password-reset/', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to send reset link',
      );
    }
  }
}
