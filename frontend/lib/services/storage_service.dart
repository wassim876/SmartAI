import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class StorageService {
  // Singleton pattern to ensure only one instance exists
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==========================================
  // 1. USER PROFILE CACHING
  // ==========================================
  // Caches the user profile locally so the app loads instantly on restart
  Future<void> cacheUserProfile(UserModel user) async {
    await _prefs?.setString('cached_user_profile', jsonEncode(user.toJson()));
  }

  UserModel? getCachedUserProfile() {
    final jsonString = _prefs?.getString('cached_user_profile');
    if (jsonString != null) {
      try {
        return UserModel.fromJson(jsonDecode(jsonString));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearCachedUserProfile() async {
    await _prefs?.remove('cached_user_profile');
  }

  // ==========================================
  // 2. APP PREFERENCES (Theme, Language, etc.)
  // ==========================================
  String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs?.setString('theme_mode', mode);
  }

  String getAppLanguage() {
    return _prefs?.getString('app_language') ?? 'en';
  }

  Future<void> setAppLanguage(String language) async {
    await _prefs?.setString('app_language', language);
  }

  bool isNotificationsEnabled() {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool('notifications_enabled', enabled);
  }

  // ==========================================
  // 3. ONBOARDING / FIRST LAUNCH
  // ==========================================
  bool isFirstLaunch() {
    return _prefs?.getBool('is_first_launch') ?? true;
  }

  Future<void> setFirstLaunchCompleted() async {
    await _prefs?.setBool('is_first_launch', false);
  }

  // ==========================================
  // 4. SECURE STORAGE WRAPPER (Optional)
  // ==========================================
  // If you need to store other sensitive data besides tokens
  Future<void> saveSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  // ==========================================
  // 5. CLEAR ALL DATA (LOGOUT)
  // ==========================================
  Future<void> clearAllLocalData() async {
    await _prefs?.clear();
    await _secureStorage.deleteAll();
  }
}
