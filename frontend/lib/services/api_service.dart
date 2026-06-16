import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_config.dart';
import '../models/activity_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    // Base options for all API calls
    _dio.options.baseUrl = '${ApiConfig.baseUrl}/api';
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    // Add Interceptors to automatically handle JWT tokens
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Automatically attach the Bearer token to every request
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle 401 Unauthorized (Token Expired)
        if (e.response?.statusCode == 401) {
          // TODO: You can implement token refresh logic here
          // For now, just clear storage and let the UI handle logout
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'refresh_token');
        }
        return handler.next(e);
      },
    ));
  }

  // ==========================================
  // 1. AI CHAT
  // ==========================================
  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        '/chat/',
        data: {'message': message},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to send message');
    }
  }

  // ==========================================
  // 2. TRANSLATE
  // ==========================================
  Future<Map<String, dynamic>> translateText({
    required String text,
    required String targetLanguage,
  }) async {
    try {
      final response = await _dio.post(
        '/translate/',
        data: {
          'text': text,
          'target_language': targetLanguage,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Translation failed');
    }
  }

  // ==========================================
  // 3. IMAGE ANALYSIS (File Upload)
  // ==========================================
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      // Create FormData for file upload
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/image-analysis/',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Image analysis failed');
    }
  }

  // ==========================================
  // 4. SPEECH TO TEXT (Audio Upload)
  // ==========================================
  Future<Map<String, dynamic>> speechToText(File audioFile) async {
    try {
      String fileName = audioFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/speech-to-text/',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Speech to text failed');
    }
  }

  // ==========================================
  // 5. HISTORY & STATS
  // ==========================================
  Future<List<ActivityModel>> getHistory() async {
    try {
      final response = await _dio.get('/history/');
      return (response.data as List)
          .map((json) => ActivityModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch history');
    }
  }

  Future<void> incrementUsage(String type, {int amount = 1}) async {
    try {
      await _dio.post(
        '/user/increment-usage/',
        data: {'type': type, 'amount': amount},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update usage');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/stats/');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch stats');
    }
  }
}
