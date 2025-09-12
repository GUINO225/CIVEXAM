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
            .setSettings(appVerificationDisabledForTesting: true)
            .catchError((error, _) {
          debugPrint('Failed to configure FirebaseAuth: $error');
          throw AuthException(
              'Failed to disable app verification for testing: $error');
        }),
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
      final user = userCredential.user;
      if (user != null) {
        await Future.wait([
          user.updateDisplayName(name),
          user.reload(),
        ]);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out failed: $e');
      }
      throw AuthException("Échec de la déconnexion");
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
