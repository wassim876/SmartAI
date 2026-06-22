import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  final _storage = const FlutterSecureStorage();

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final saved = await _storage.read(key: 'darkMode');
      if (saved == 'true') {
        _isDarkMode = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    _storage.write(key: 'darkMode', value: value.toString());
    notifyListeners();
  }
}
