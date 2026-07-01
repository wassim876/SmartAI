// lib/services/admin_notification_service.dart
//
// Writes admin-facing alerts to the Supabase `notifications` table
// (replaces the old Firestore `admin_notifications` collection).
import '../core/supabase_config.dart';

class AdminNotificationService {
  static Future<void> notify({
    required String type,
    required String title,
    required String message,
  }) async {
    try {
      await supabase.from('notifications').insert({
        'type': type,
        'title': title,
        'body': message,
        'read': false,
      });
    } catch (_) {}
  }

  static Future<void> onNewUser(String userName, String email) async {
    await notify(
      type: 'new_user',
      title: 'New user registered',
      message: '$userName ($email) just created an account',
    );
  }

  static Future<void> onNewChat(String userId) async {
    await notify(
      type: 'new_chat',
      title: 'AI conversation created',
      message: 'User $userId started a new chat session',
    );
  }

  static Future<void> onNewReview(String userName, int rating) async {
    await notify(
      type: 'new_review',
      title: 'New app review',
      message: '$userName left a $rating-star review',
    );
  }

  static Future<void> onImageAnalysis(String userId) async {
    await notify(
      type: 'image_analysis',
      title: 'Image analysis used',
      message: 'User $userId submitted an image for analysis',
    );
  }

  static Future<void> onSpeechToText(String userId) async {
    await notify(
      type: 'speech',
      title: 'Speech to text used',
      message: 'User $userId transcribed an audio file',
    );
  }
}
