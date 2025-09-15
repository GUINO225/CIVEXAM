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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign out failed: $e');
      }
      throw AuthException("Échec de la déconnexion");
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(provider);
      }
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw AuthException('Connexion Google annulée');
      }
      final authentication = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user') {
        throw AuthException('Connexion Google annulée');
      }
      if (e.code == 'account-exists-with-different-credential') {
        throw AuthException(
            'Un compte existe déjà avec un autre fournisseur de connexion');
      }
      throw AuthException(_messageFromCode(e.code, e.message));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Connexion Google impossible');
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
