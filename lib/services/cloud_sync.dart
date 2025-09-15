
import 'dart:async';
import 'package:flutter/foundation.dart'
    show debugPrint, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart' deferred as firebase_options;
import 'package:shared_preferences/shared_preferences.dart';

class CloudSync {
  static bool _initTried = false;
  static bool _ready = false;

  static const String _kAllowAnonymous = 'allowAnonymousSignIn';

  static String _currentPlatform() {
    if (kIsWeb) {
      return 'web';
    }
    try {
      return defaultTargetPlatform.name.toLowerCase();
    } catch (_) {
      return 'unknown';
    }
  }

  static Future<bool> ensureInitialized() async {
    if (_ready || _initTried) return _ready;
    try {
      if (Firebase.apps.isEmpty) {
        FirebaseOptions? options;
        try {
          await firebase_options.loadLibrary();
          options = firebase_options.DefaultFirebaseOptions.currentPlatform;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[CloudSync] firebase_options.dart not found: $e');
          }
        }
        if (options != null) {
          await Firebase.initializeApp(options: options);
        } else {
          await Firebase.initializeApp();
        }
      }
      final signedIn = await _ensureSignedIn();
      if (!signedIn) {
        if (kDebugMode) {
          debugPrint('[CloudSync] No authenticated user.');
        }
        _ready = false;
        _initTried = false;
        return false;
      }
      _ready = true;
      _initTried = true;
      if (kDebugMode) debugPrint('[CloudSync] Firebase initialized.');
    } catch (e) {
      if (kDebugMode) debugPrint('[CloudSync] Firebase init skipped: $e');
      _ready = false;
      _initTried = false;
    }
    return _ready;
  }

  /// Ensures there is an authenticated Firebase user.
  static Future<bool> _ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return true;

    final prefs = await SharedPreferences.getInstance();
    final allowAnon = prefs.getBool(_kAllowAnonymous) ?? true;
    if (!allowAnon) return false;

    try {
      await auth.signInAnonymously();
      return auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> uploadAttempt({
    required String subject,
    required String chapter,
    required int score,
    required int total,
    required int durationSeconds,
    required DateTime timestamp,
  }) async {
    try {
      if (!await ensureInitialized()) {
        if (kDebugMode) {
          debugPrint('[CloudSync] Upload skipped: user not signed in.');
        }
        return;
      }
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (kDebugMode) {
          debugPrint('[CloudSync] No authenticated user. Please sign in.');
        }
        return;
      }
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('attempts');
      await col.add({
        'subject': subject,
        'chapter': chapter,
        'score': score,
        'total': total,
        'durationSeconds': durationSeconds,
        'timestamp': timestamp.toUtc(),
        'platform': _currentPlatform(),
        'version': 1,
      });
      if (kDebugMode) debugPrint('[CloudSync] Attempt uploaded.');
    } catch (e) {
      if (kDebugMode) debugPrint('[CloudSync] Upload skipped: $e');
    }
  }
}
