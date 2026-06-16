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
        'username': email.split('@')[0], // Fallback username
        'email': email,
        'first_name': name,
        'password': password,
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return null;

      final response = await _dio.get(
        '/profile/',
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
