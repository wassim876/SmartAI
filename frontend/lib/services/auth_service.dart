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
        'username': email,
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
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register/', data: {
        'username': email,
        'email': email,
        'first_name': name,
        'password': password,
      });
      return response.statusCode == 201;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data.values.first
          : 'Registration failed';
      throw Exception(message);
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
        if (data is Map<String, dynamic> && data['success'] == true && data['data'] != null) {
          usersData = data['data'] as List<dynamic>;
        } 
        // Check if response is a raw list
        else if (data is List<dynamic>) {
          usersData = data;
        } 
        else {
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
            isAdmin: (json['is_staff'] ?? false) || (json['is_superuser'] ?? false),
            isPremium: json['is_premium'] ?? false,
            dailyMessagesUsed: json['daily_messages_used'] ?? 0,
            dailyMessagesLimit: json['daily_messages_limit'] ?? 50,
            monthlySpeechMinutesUsed: json['monthly_speech_minutes_used'] ?? 0,
            monthlySpeechMinutesLimit: json['monthly_speech_minutes_limit'] ?? 10,
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

  Future<bool> isTokenValid() async {
    try {
      final token = await _storage.read(key: 'access_token');
      return token != null;
    } catch (e) {
      return false;
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