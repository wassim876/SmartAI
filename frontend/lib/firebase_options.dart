// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-9i0VJgPDcDBr4R6Wi-gs-UyG3E4-fvE',
    authDomain: 'smart-ai-7bb69.firebaseapp.com',
    projectId: 'smart-ai-7bb69',
    storageBucket: 'smart-ai-7bb69.firebasestorage.app',
    messagingSenderId: '919783857163',
    appId: '1:919783857163:web:6767ff5abc95e464aabb0e',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-9i0VJgPDcDBr4R6Wi-gs-UyG3E4-fvE',
    appId: '1:919783857163:android:abcdef1234567890',
    messagingSenderId: '919783857163',
    projectId: 'smart-ai-7bb69',
    authDomain: 'smart-ai-7bb69.firebaseapp.com',
    storageBucket: 'smart-ai-7bb69.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-9i0VJgPDcDBr4R6Wi-gs-UyG3E4-fvE',
    appId: '1:919783857163:ios:abcdef1234567890',
    messagingSenderId: '919783857163',
    projectId: 'smart-ai-7bb69',
    authDomain: 'smart-ai-7bb69.firebaseapp.com',
    storageBucket: 'smart-ai-7bb69.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-9i0VJgPDcDBr4R6Wi-gs-UyG3E4-fvE',
    appId: '1:919783857163:macos:abcdef1234567890',
    messagingSenderId: '919783857163',
    projectId: 'smart-ai-7bb69',
    authDomain: 'smart-ai-7bb69.firebaseapp.com',
    storageBucket: 'smart-ai-7bb69.firebasestorage.app',
  );
}
