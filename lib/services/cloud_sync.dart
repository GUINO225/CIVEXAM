
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart' deferred as firebase_options;

class CloudSync {
  static bool _initTried = false;
  static bool _ready = false;

  static String _currentPlatform() {
    try {
      return Platform.operatingSystem;
    } catch (_) {
      try {
        return defaultTargetPlatform.name.toLowerCase();
      } catch (_) {
        return 'unknown';
      }
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
      await _ensureSignedIn();
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

  static Future<void> _ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
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
      if (!await ensureInitialized()) return;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
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
