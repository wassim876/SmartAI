// lib/services/ai_service.dart
//
// Client wrapper over the NVIDIA-NIM Edge Functions (nim-chat / nim-translate /
// nim-transcribe / nim-tts). Each call goes through supabase.functions.invoke,
// which attaches the user's JWT automatically.
import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

/// Thrown when the server-side daily message quota is exhausted (HTTP 429).
class AiQuotaException implements Exception {
  final String message;
  AiQuotaException(this.message);
  @override
  String toString() => message;
}

class AiService {
  /// Chat + optional image vision. `messages` are OpenAI-style
  /// `{role: 'user'|'assistant'|'system', content: '...'}`. `imageDataUrl` is a
  /// `data:image/...;base64,...` URI (routes the request to the vision model).
  Future<String> chat({
    required List<Map<String, String>> messages,
    String? imageDataUrl,
  }) async {
    final data = await _invoke('nim-chat', {
      'messages': messages,
      if (imageDataUrl != null) 'image': imageDataUrl,
    });
    final reply = data['reply'];
    if (reply is String) return reply;
    throw Exception('Chat failed');
  }

  Future<String> translate({
    required String text,
    required String targetLang,
    String? sourceLang,
  }) async {
    final data = await _invoke('nim-translate', {
      'text': text,
      'targetLang': targetLang,
      if (sourceLang != null) 'sourceLang': sourceLang,
    });
    final t = data['translation'];
    if (t is String) return t;
    throw Exception('Translation failed');
  }

  Future<String> transcribe({
    required String audioBase64,
    String mimeType = 'audio/wav',
    String language = 'en-US',
  }) async {
    final data = await _invoke('nim-transcribe', {
      'audio': audioBase64,
      'mimeType': mimeType,
      'language': language,
    });
    final t = data['transcript'];
    if (t is String) return t;
    throw Exception('Transcription failed');
  }

  /// Text-to-speech → decoded audio bytes (mp3).
  Future<Uint8List> tts(String text, {String? voice}) async {
    final data = await _invoke('nim-tts', {
      'text': text,
      if (voice != null) 'voice': voice,
    });
    final audio = data['audio'];
    if (audio is String) return base64Decode(audio);
    throw Exception('Voice output failed');
  }

  Future<Map<String, dynamic>> _invoke(
      String name, Map<String, dynamic> body) async {
    try {
      final res = await supabase.functions.invoke(name, body: body);
      final data = res.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw Exception('Unexpected response from $name');
    } on FunctionException catch (e) {
      final details = e.details;
      final msg = (details is Map
              ? (details['message'] ?? details['error'])
              : null)
          ?.toString();
      if (e.status == 429) {
        throw AiQuotaException(msg ?? 'Daily message limit reached');
      }
      throw Exception(msg ?? '$name failed (${e.status})');
    }
  }
}
