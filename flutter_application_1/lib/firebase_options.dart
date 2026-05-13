import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web config is not set.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'REPLACE_ME',
          appId: 'REPLACE_ME',
          messagingSenderId: 'REPLACE_ME',
          projectId: 'REPLACE_ME',
          storageBucket: 'REPLACE_ME',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase options are configured only for Android in this lab.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }
}
