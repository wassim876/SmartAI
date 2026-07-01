import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Connection settings for the local Supabase stack (`supabase start`).
///
/// The anon key is the well-known local development key printed by
/// `supabase status` — it is not a secret and is safe to embed for local dev.
/// Swap these for the hosted project URL + publishable key when deploying.
class SupabaseConfig {
  static String get url {
    if (kIsWeb) {
      return 'http://127.0.0.1:54321';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator reaches the host via 10.0.2.2.
        return 'http://10.0.2.2:54321';
      default:
        return 'http://127.0.0.1:54321';
    }
  }

  static const String publishableKey =
      'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';
}

/// Global accessor for the initialized Supabase client.
SupabaseClient get supabase => Supabase.instance.client;
