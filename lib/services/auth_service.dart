import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Exception thrown for authentication failures with a user-friendly message.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Disables Firebase's reCAPTCHA requirement for phone authentication only
  /// during debug builds so developers aren't blocked during local testing.
  AuthService() {
    if (kDebugMode) {
      unawaited(
        FirebaseAuth.instance
            .setSettings(appVerificationDisabledForTesting: true),
      );
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  Future<UserCredential> registerWithEmail(
      String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  String _messageFromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email invalide';
      case 'user-disabled':
        return 'Utilisateur désactivé';
      case 'user-not-found':
        return 'Utilisateur introuvable';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Email déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible';
      default:
        return "Erreur d'authentification";
    }
  }
}
