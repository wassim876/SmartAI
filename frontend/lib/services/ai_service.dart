// lib/services/ai_service.dart
//
// Client wrapper over the NVIDIA-NIM Edge Functions (nim-chat / nim-translate /
// nim-models). Each call goes through supabase.functions.invoke, which attaches
// the user's JWT automatically.
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

/// Thrown when the server-side daily message quota is exhausted (HTTP 429).
class AiQuotaException implements Exception {
  final String message;
  AiQuotaException(this.message);
  @override
  String toString() => message;
}

/// One selectable chat model, as advertised by the `nim-models` function.
///
/// The list is served by the backend rather than hardcoded here: NVIDIA retires
/// models regularly, so the set of working ids has to be changeable with a
/// function deploy instead of an app-store release.
class AiModel {
  final String id;
  final String label;
  final bool vision;

  const AiModel({required this.id, required this.label, required this.vision});

  factory AiModel.fromMap(Map<String, dynamic> map) => AiModel(
        id: map['id'] as String,
        label: (map['label'] ?? map['id']) as String,
        vision: map['vision'] == true,
      );

  @override
  bool operator ==(Object other) => other is AiModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// What `nim-models` returns: the allowlist plus the server's defaults.
class AiModelCatalog {
  final List<AiModel> models;
  final String defaultModel;
  final String visionModel;

  const AiModelCatalog({
    required this.models,
    required this.defaultModel,
    required this.visionModel,
  });

  static const empty =
      AiModelCatalog(models: [], defaultModel: '', visionModel: '');
}

class AiService {
  /// The models this user may pick from. Cached per app run — the allowlist
  /// only changes on a function deploy.
  static AiModelCatalog? _cachedCatalog;

  /// Lists the selectable chat models. Returns an empty catalog (rather than
  /// throwing) if the lookup fails, so the chat screen still works with the
  /// server-side default when the picker can't be populated.
  Future<AiModelCatalog> listModels({bool refresh = false}) async {
    if (!refresh && _cachedCatalog != null) return _cachedCatalog!;
    try {
      final data = await _invoke('nim-models', {});
      final raw = data['models'];
      final models = raw is List
          ? raw
              .whereType<Map>()
              .map((m) => AiModel.fromMap(Map<String, dynamic>.from(m)))
              .toList()
          : <AiModel>[];
      return _cachedCatalog = AiModelCatalog(
        models: models,
        defaultModel: (data['defaultModel'] ?? '') as String,
        visionModel: (data['visionModel'] ?? '') as String,
      );
    } catch (_) {
      return AiModelCatalog.empty;
    }
  }

  /// Chat + optional image vision. `messages` are OpenAI-style
  /// `{role: 'user'|'assistant'|'system', content: '...'}`. `imageDataUrl` is a
  /// `data:image/...;base64,...` URI (routes the request to the vision model).
  ///
  /// [model] must be one of the ids from [listModels]; the server rejects
  /// anything else. Omit it to use the server-side default. When an image is
  /// attached and [model] can't see images, the server transparently uses its
  /// vision model instead — [ChatResult.model] reports what actually ran.
  Future<ChatResult> chat({
    required List<Map<String, String>> messages,
    String? imageDataUrl,
    String? model,
  }) async {
    final data = await _invoke('nim-chat', {
      'messages': messages,
      if (imageDataUrl != null) 'image': imageDataUrl,
      if (model != null && model.isNotEmpty) 'model': model,
    });
    final reply = data['reply'];
    if (reply is String) {
      return ChatResult(reply: reply, model: (data['model'] ?? '') as String);
    }
    throw Exception('Chat failed');
  }

  Future<String> translate({
    required String text,
    required String targetLang,
    String? sourceLang,
    String? model,
  }) async {
    final data = await _invoke('nim-translate', {
      'text': text,
      'targetLang': targetLang,
      if (sourceLang != null) 'sourceLang': sourceLang,
      if (model != null && model.isNotEmpty) 'model': model,
    });
    final t = data['translation'];
    if (t is String) return t;
    throw Exception('Translation failed');
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

/// A chat reply plus the model that actually produced it (which may differ from
/// the requested one — see [AiService.chat]).
class ChatResult {
  final String reply;
  final String model;

  const ChatResult({required this.reply, required this.model});
}
