// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWAIrkydvaNel2li2mKwrF2qbBag7M98Q',
    appId: '1:522640251078:web:8157ff3781f38b4b0b9f86',
    messagingSenderId: '522640251078',
    projectId: 'civexam-54e17',
    storageBucket: 'civexam-54e17.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWAIrkydvaNel2li2mKwrF2qbBag7M98Q',
    appId: '1:522640251078:android:c59b78f08fbdde5870dfc7',
    messagingSenderId: '522640251078',
    projectId: 'civexam-54e17',
    storageBucket: 'civexam-54e17.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBWAIrkydvaNel2li2mKwrF2qbBag7M98Q',
    appId: '1:522640251078:ios:c59b78f08fbdde5870dfc7',
    messagingSenderId: '522640251078',
    projectId: 'civexam-54e17',
    storageBucket: 'civexam-54e17.firebasestorage.app',
    iosClientId:
        '522640251078-rtj679r8biudv9ri3v77ne8lh6j0eth0.apps.googleusercontent.com',
    iosBundleId: 'com.company.civexam',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    iosBundleId: '',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
  );
}

