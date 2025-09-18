import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile.dart';
import 'user_profile_service.dart';

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
  final UserProfileService _userProfileService = UserProfileService();

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
        await _ensureUserProfile(user, fallbackName: name);
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
        final userCredential = await _auth.signInWithPopup(provider);
        final user = userCredential.user;
        if (user != null) {
          await _ensureUserProfile(user);
        }
        return userCredential;
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
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _ensureUserProfile(
          user,
          fallbackName: account.displayName ?? account.email,
        );
      }
      return userCredential;
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

  Future<void> _ensureUserProfile(User user, {String? fallbackName}) async {
    try {
      final uid = user.uid;
      final existingProfile = await _userProfileService.loadProfile(uid);
      if (existingProfile != null) {
        return;
      }
      final resolvedName = _resolveName(user.displayName, fallbackName, user.email);
      final names = _splitName(resolvedName);
      final profile = UserProfile(
        firstName: names['firstName'] ?? '',
        lastName: names['lastName'] ?? '',
        nickname: names['nickname'] ?? '',
        profession: '',
        photoUrl: '',
      );
      await _userProfileService.saveProfile(profile);
    } catch (e) {
      if (kDebugMode) {
        print('Profile initialization failed: $e');
      }
      throw AuthException("Échec de l'initialisation du profil utilisateur");
    }
  }

  String _resolveName(String? primary, String? secondary, String? email) {
    final first = primary?.trim();
    if (first != null && first.isNotEmpty) {
      return first;
    }
    final second = secondary?.trim();
    if (second != null && second.isNotEmpty) {
      return second;
    }
    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) {
      return mail;
    }
    return '';
  }

  Map<String, String> _splitName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return {'firstName': '', 'lastName': '', 'nickname': ''};
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final nickname = firstName.isNotEmpty ? firstName : trimmed;
    return {
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
    };
  }
}
