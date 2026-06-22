import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  final _storage = const FlutterSecureStorage();

  Locale get locale => _locale;

  static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
    'de': 'Deutsch',
    'es': 'Español',
    'tr': 'Türkçe',
    'ru': 'Русский',
    'zh': '中文',
  };

  static const Map<String, String> languageFlags = {
    'en': '🇬🇧',
    'fr': '🇫🇷',
    'ar': '🇸🇦',
    'de': '🇩🇪',
    'es': '🇪🇸',
    'tr': '🇹🇷',
    'ru': '🇷🇺',
    'zh': '🇨🇳',
  };

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final saved = await _storage.read(key: 'language');
      if (saved != null) {
        _locale = Locale(saved);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    try {
      await _storage.write(key: 'language', value: locale.languageCode);
    } catch (_) {}
    notifyListeners();
  }
}
