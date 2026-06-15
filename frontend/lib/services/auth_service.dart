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
        await _storage.write(key: 'access_token', value: response.data['access']);
        await _storage.write(key: 'refresh_token', value: response.data['refresh']);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login Failed: ${e.response?.data ?? e.message}');
      return false;
    }
  }
}