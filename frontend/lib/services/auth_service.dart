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
      // Standard SimpleJWT endpoint
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
        'username': email, // Use full email as username to ensure uniqueness
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

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch users');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isTokenValid() async {
    try {
      final token = await _storage.read(key: 'access_token');
      // A more robust app would decode the JWT to check expiry,
      // but checking for existence is enough to trigger a profile fetch.
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
      // Matches your ForgotPasswordScreen call
      await _dio.post('/password-reset/', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to send reset link',
      );
    }
  }
}
