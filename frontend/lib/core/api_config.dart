import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web
      return 'http://127.0.0.1:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android Emulator
        return 'http://10.0.2.2:8000';

      default:
        // Windows, Linux, macOS
        return 'http://127.0.0.1:8000';
    }
  }
}
