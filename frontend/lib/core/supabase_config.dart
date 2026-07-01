import 'package:supabase_flutter/supabase_flutter.dart';

/// Connection settings for the hosted Supabase project.
///
/// The publishable key is a client-side key (safe to embed); row-level security
/// governs what it can read/write. For local development against `supabase
/// start`, swap `url` for the local URL and the local publishable key.
class SupabaseConfig {
  static const String url = 'https://bxuwjcliikrolkgyllyo.supabase.co';

  static const String publishableKey =
      'sb_publishable_SE612uHcN-xNQPjxrmGfUQ_AOnP4E1n';
}

/// Global accessor for the initialized Supabase client.
SupabaseClient get supabase => Supabase.instance.client;
