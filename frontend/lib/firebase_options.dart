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
    appId: '1:919783857163:web:6767ff5abc95e464aabb0e',
    messagingSenderId: '919783857163',
    projectId: 'smart-ai-7bb69',
    authDomain: 'smart-ai-7bb69.firebaseapp.com',
    storageBucket: 'smart-ai-7bb69.firebasestorage.app',
    measurementId: 'G-TBSXT04569',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPVGpa6riISRug6UOjFGufuejxySjKVcU',
    appId: '1:919783857163:android:b79828ea094606b9aabb0e',
    messagingSenderId: '919783857163',
    projectId: 'smart-ai-7bb69',
    storageBucket: 'smart-ai-7bb69.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxRkh1w9ZCHl5w0kcKl8CWVtZm1SmDr6M',
    appId: '1:919783857163:ios:817f281862eb606aaabb0e',
    messagingSenderId: '919783857163',
    projectId: 'smart-ai-7bb69',
    storageBucket: 'smart-ai-7bb69.firebasestorage.app',
    iosClientId: '919783857163-e4iot93k1n2u1frgktta6n26lsj7qt9q.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartai',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDxRkh1w9ZCHl5w0kcKl8CWVtZm1SmDr6M',
    appId: '1:919783857163:ios:817f281862eb606aaabb0e',
    messagingSenderId: '919783857163',
    projectId: 'smart-ai-7bb69',
    storageBucket: 'smart-ai-7bb69.firebasestorage.app',
    iosClientId: '919783857163-e4iot93k1n2u1frgktta6n26lsj7qt9q.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartai',
  );
}
