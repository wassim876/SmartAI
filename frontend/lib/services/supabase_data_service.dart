// lib/services/supabase_data_service.dart
//
// Supabase (PostgREST + Realtime) data layer. Replaces the old Firestore
// service. Reads return raw `profiles`/table rows with snake_case keys;
// per-user list reads are realtime streams (tables are in the
// supabase_realtime publication — see the init migration).
import '../core/supabase_config.dart';
import '../models/user_model.dart';

class SupabaseDataService {
  String? get _uid => supabase.auth.currentUser?.id;

  static const List<String> _ownedTables = [
    'chat_messages', 'chat_sessions', 'image_analyses',
    'speech_transcriptions', 'translations', 'user_activities', 'reviews',
  ];

  // Legacy camelCase keys (from UI/providers) -> snake_case columns, so existing
  // write call sites keep working without being rewritten everywhere.
  static const Map<String, String> _columnAliases = {
    'uid': 'id',
    'displayName': 'display_name',
    'photoURL': 'photo_url',
    'isPremium': 'is_premium',
    'isActive': 'is_active',
    'isAdmin': 'is_admin',
    'dailyMessagesUsed': 'daily_messages_used',
    'dailyMessagesLimit': 'daily_messages_limit',
    'lastLogin': 'last_login',
  };

  Map<String, dynamic> _cols(Map<String, dynamic> data) =>
      data.map((k, v) => MapEntry(_columnAliases[k] ?? k, v));

  // ============================== USER ==============================

  Future<UserModel> getUserProfile() async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');

    final row =
        await supabase.from('profiles').select().eq('id', uid).maybeSingle();
    if (row != null) return UserModel.fromMap(row);

    // The handle_new_user trigger normally creates this; provision defensively.
    final user = supabase.auth.currentUser!;
    final created = await supabase.from('profiles').insert({
      'id': uid,
      'email': user.email,
      'username': user.userMetadata?['username'] ??
          user.email?.split('@').first ??
          'user',
      'display_name': user.userMetadata?['display_name'] ?? 'User',
    }).select().single();
    return UserModel.fromMap(created);
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await supabase.from('profiles').update(_cols(data)).eq('id', uid);
  }

  Future<void> touchLastLogin() async {
    final uid = _uid;
    if (uid == null) return;
    await supabase.from('profiles').update(
        {'last_login': DateTime.now().toUtc().toIso8601String()}).eq('id', uid);
  }

  /// Server-side atomic increment with limit enforcement (raises when capped).
  Future<void> incrementDailyMessages() async {
    await supabase.rpc('increment_daily_messages');
  }

  Future<void> resetDailyUsage() async {
    final uid = _uid;
    if (uid == null) return;
    await supabase
        .from('profiles')
        .update({'daily_messages_used': 0}).eq('id', uid);
  }

  // ============================== CHAT ==============================

  Future<void> saveChatMessage({
    required String message,
    required String response,
    String model = 'nvidia-nim',
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await supabase.from('chat_messages').insert({
      'user_id': uid,
      'message': message,
      'response': response,
      'model': model,
    });
  }

  Stream<List<Map<String, dynamic>>> getChatHistory({int limit = 50}) =>
      _userStream('chat_messages', limit: limit);

  // ========================== IMAGE ANALYSES =========================

  Future<void> saveImageAnalysis({
    required String imageUrl,
    required String analysisResult,
    String imageType = 'general',
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await supabase.from('image_analyses').insert({
      'user_id': uid,
      'image_url': imageUrl,
      'analysis_result': analysisResult,
      'image_type': imageType,
    });
  }

  Stream<List<Map<String, dynamic>>> getImageAnalyses({int limit = 50}) =>
      _userStream('image_analyses', limit: limit);

  // ========================= SPEECH TO TEXT ==========================

  Future<void> saveSpeechTranscription({
    required String audioUrl,
    required String transcription,
    double duration = 0,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await supabase.from('speech_transcriptions').insert({
      'user_id': uid,
      'audio_url': audioUrl,
      'transcription': transcription,
      'duration': duration,
    });
  }

  Stream<List<Map<String, dynamic>>> getSpeechTranscriptions({int limit = 50}) =>
      _userStream('speech_transcriptions', limit: limit);

  // =========================== TRANSLATION ===========================

  Future<void> saveTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await supabase.from('translations').insert({
      'user_id': uid,
      'original_text': originalText,
      'translated_text': translatedText,
      'source_lang': sourceLang,
      'target_lang': targetLang,
    });
  }

  Stream<List<Map<String, dynamic>>> getTranslations({int limit = 50}) =>
      _userStream('translations', limit: limit);

  // ============================ ACTIVITY =============================

  Future<void> logActivity(String action,
      {Map<String, dynamic>? details}) async {
    final uid = _uid;
    if (uid == null) return;
    await supabase.from('user_activities').insert({
      'user_id': uid,
      'action': action,
      'details': details ?? <String, dynamic>{},
    });
  }

  Stream<List<Map<String, dynamic>>> getUserActivities({int limit = 50}) =>
      _userStream('user_activities', limit: limit);

  // ========================== CHAT SESSIONS ==========================

  Future<List<Map<String, dynamic>>> getChatSessions({int limit = 50}) async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await supabase
        .from('chat_sessions')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>?> getChatSession(String id) async {
    return supabase.from('chat_sessions').select().eq('id', id).maybeSingle();
  }

  /// Insert (id == null) or update a chat session. Returns the row id.
  Future<String> saveChatSession({
    String? id,
    required String title,
    required List<Map<String, dynamic>> messages,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    if (id == null) {
      final row = await supabase
          .from('chat_sessions')
          .insert({'user_id': uid, 'title': title, 'messages': messages})
          .select('id')
          .single();
      return row['id'] as String;
    }
    await supabase.from('chat_sessions').update({
      'title': title,
      'messages': messages,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
    return id;
  }

  Future<void> deleteChatSession(String id) async {
    await supabase.from('chat_sessions').delete().eq('id', id);
  }

  // ============================= REVIEWS =============================

  Future<void> saveReview({required int rating, required String comment}) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await supabase
        .from('reviews')
        .insert({'user_id': uid, 'rating': rating, 'comment': comment});
  }

  /// Admin-facing stream of all reviews (RLS lets admins read across users).
  Stream<List<Map<String, dynamic>>> getReviews({int limit = 100}) {
    return supabase
        .from('reviews')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(limit);
  }

  // ============================== ADMIN ==============================

  /// Aggregated admin dashboard metrics (admin-only; RPC raises otherwise).
  Future<Map<String, dynamic>> getAdminStats() async {
    final res = await supabase.rpc('admin_dashboard_stats');
    return Map<String, dynamic>.from(res as Map);
  }

  // ===================== REPORTS (admin exports) =====================

  Future<List<Map<String, dynamic>>> reportUsers() async {
    final rows = await supabase
        .from('profiles')
        .select(
            'email, username, display_name, is_premium, is_active, is_admin, daily_messages_used, daily_messages_limit, created_at, last_login')
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> reportReviews() async {
    final rows = await supabase
        .from('reviews')
        .select('rating, comment, user_id, created_at')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> reportActivity() async {
    final rows = await supabase
        .from('user_activities')
        .select('action, details, user_id, created_at')
        .order('created_at', ascending: false)
        .limit(2000);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> reportAiUsage() async {
    final stats = await getAdminStats();
    final breakdown = (stats['service_breakdown'] as List?) ?? const [];
    final rows = breakdown
        .map((b) => {
              'service': (b as Map)['label'],
              'requests': b['count'],
            })
        .toList();
    final total = rows.fold<int>(
        0, (s, r) => s + ((r['requests'] as num?)?.toInt() ?? 0));
    rows.add({'service': 'Total', 'requests': total});
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<UserModel>> getAllUsers() async {
    final rows = await supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows).map(UserModel.fromMap).toList();
  }

  Future<void> adminUpdateUser(String userId, Map<String, dynamic> data) async {
    await supabase.from('profiles').update(_cols(data)).eq('id', userId);
  }

  /// Deletes the user's owned rows (admin delete policy permits it) and their
  /// profile. NOTE: the auth.users row itself is left orphaned — a hard auth
  /// deletion needs the service role and lives in an Edge Function (Phase 2).
  Future<void> adminDeleteUser(String userId) async {
    for (final table in _ownedTables) {
      await supabase.from(table).delete().eq('user_id', userId);
    }
    await supabase.from('profiles').delete().eq('id', userId);
  }

  // ============================== HELPERS ============================

  Stream<List<Map<String, dynamic>>> _userStream(String table,
      {int limit = 50}) {
    final uid = _uid;
    if (uid == null) {
      return const Stream<List<Map<String, dynamic>>>.empty();
    }
    return supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
  }
}
