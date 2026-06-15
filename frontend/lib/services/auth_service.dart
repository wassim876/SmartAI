import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_config.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/token/', // Based on your Django urls.py
        data: {
          'username': email, // Django defaults to 'username' for auth
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Save the JWT tokens securely
        await _storage.write(
            key: 'access_token', value: response.data['access']);
        await _storage.write(
            key: 'refresh_token', value: response.data['refresh']);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login Failed: ${e.response?.data ?? e.message}');
      rethrow; // Rethrow the exception to be caught by the UI layer
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/register/', // Ensure this matches your Django URL
        data: {
          'username': email, // Using email as username is common
          'email': email,
          'password': password,
          'first_name': name,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      print('Registration Failed: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      // Placeholder for password reset API
      await Future.delayed(const Duration(seconds: 2));
    } on DioException catch (e) {
      print('Reset Password Failed: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (accessToken != null && refreshToken != null) {
        // Blacklist the refresh token on the server
        await _dio.post(
          '${ApiConfig.baseUrl}/api/logout/',
          data: {'refresh': refreshToken},
          options: Options(
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );
      }
    } on DioException catch (e) {
      // Even if the server call fails (e.g. token already expired),
      // proceed to clear local storage so the user is logged out locally.
      print('Logout request failed: ${e.response?.data ?? e.message}');
    } finally {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
    }
  }
}
