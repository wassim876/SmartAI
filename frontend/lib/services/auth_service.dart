// lib/services/auth_service.dart
//
// Supabase authentication: email/password + Google/GitHub OAuth.
// Profile rows are provisioned by the `handle_new_user` DB trigger on signup.
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/user_model.dart';
import 'supabase_data_service.dart';

class AuthService {
  final SupabaseDataService _data = SupabaseDataService();

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
  User? get currentUser => supabase.auth.currentUser;
  bool get isAuthenticated => supabase.auth.currentUser != null;

  // ==========================================
  // EMAIL / PASSWORD
  // ==========================================
  Future<UserModel?> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'display_name': username},
    );
    if (res.user == null) {
      throw Exception('Sign up failed');
    }
    // profiles row is created by the handle_new_user trigger.
    return _data.getUserProfile();
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth
        .signInWithPassword(email: email, password: password);
    if (res.user == null) {
      throw Exception('Sign in failed');
    }
    await _data.touchLastLogin();
    return _data.getUserProfile();
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  }

  Future<void> signInWithGitHub() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.github,
    );
  }

  Future<void> signOut() => supabase.auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      supabase.auth.resetPasswordForEmail(email);

  /// Completes a password reset started with [sendPasswordResetEmail].
  /// The recovery email carries a 6-digit [token]; verifying it opens a
  /// short-lived recovery session that we use to set the new password. We
  /// sign out afterwards so the user re-authenticates with the new password.
  Future<void> resetPasswordWithOtp({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
    await supabase.auth.signOut();
  }

  // ==========================================
  // PROFILE / CREDENTIALS
  // ==========================================
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    bool clearPhoto = false,
  }) async {
    final data = <String, dynamic>{};
    if (displayName != null) data['display_name'] = displayName;
    if (clearPhoto) {
      data['photo_url'] = null;
    } else if (photoURL != null) {
      data['photo_url'] = photoURL;
    }
    if (data.isNotEmpty) {
      await _data.updateUserProfile(data);
    }
    if (displayName != null) {
      await supabase.auth
          .updateUser(UserAttributes(data: {'display_name': displayName}));
    }
  }

  Future<void> changePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> changeEmail(String newEmail) async {
    await supabase.auth.updateUser(UserAttributes(email: newEmail));
  }

  // ==========================================
  // ADMIN (require the service role → Edge Functions, see Phase 2)
  // ==========================================
  Future<void> adminCreateUser({
    required String username,
    required String email,
    required String password,
    bool isAdmin = false,
    bool isPremium = false,
  }) async {
    await supabase.functions.invoke('admin-create-user', body: {
      'username': username,
      'email': email,
      'password': password,
      'is_admin': isAdmin,
      'is_premium': isPremium,
    });
  }

  Future<void> adminDeleteAuthUser(String userId) async {
    await supabase.functions
        .invoke('admin-delete-user', body: {'user_id': userId});
  }
}
