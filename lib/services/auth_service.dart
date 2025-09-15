import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Exception thrown for authentication failures with a user-friendly message.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code, e.message));
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
          user.sendEmailVerification(),
        ]);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code, e.message));
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw AuthException('Connexion Google annulée');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code, e.message));
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      if (kDebugMode) {
        print('Google sign in failed: $e');
      }
      throw AuthException('Connexion Google échouée');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        GoogleSignIn().signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Sign out failed: $e');
      }
      throw AuthException("Échec de la déconnexion");
    }
  }

  String _messageFromCode(String code, [String? message]) {
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
      case 'network-request-failed':
        return 'Problème de connexion réseau';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter pour continuer';
      case 'internal-error':
        if (message != null && message.contains('CONFIGURATION_NOT_FOUND')) {
          return 'Configuration d’authentification invalide – reCAPTCHA manquant.';
        }
        return "Erreur interne d'authentification";
      default:
        return "Erreur d'authentification";
    }
  }

  @visibleForTesting
  String messageFromCodeForTest(String code, [String? message]) =>
      _messageFromCode(code, message);
}
