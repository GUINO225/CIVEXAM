import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'play_screen.dart';
import '../services/question_loader.dart';

/// Initial splash screen showing the app logo before navigating to login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    try {
      final auth = FirebaseAuth.instance;
      final userFuture = auth
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 5));
      await Future.wait([
        QuestionLoader.loadENA(),
        userFuture,
      ]);
      if (!mounted) return;
      final user = await userFuture;
      if (user != null) {
        try {
          await auth.currentUser?.reload();
        } catch (_) {}
      }
      var refreshedUser = auth.currentUser;
      refreshedUser ??= user;
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        final unverifiedUser = refreshedUser;
        try {
          await auth.signOut();
        } catch (_) {}
        _goToLogin('Veuillez vérifier votre email',
            unverifiedUser: unverifiedUser);
        return;
      }
      final next =
          refreshedUser == null ? const LoginScreen() : const PlayScreen();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => next),
      );
    } on TimeoutException {
      _goToLogin('La connexion a expiré. Veuillez vous reconnecter.');
    } catch (_) {
      _goToLogin('Connexion impossible. Veuillez vous reconnecter.');
    }
  }

  void _goToLogin(String message, {User? unverifiedUser}) {
    if (!mounted) return;
    // Show the message before navigating so it remains visible afterwards.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => unverifiedUser == null
            ? const LoginScreen()
            : LoginScreen(initialUnverifiedUser: unverifiedUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo_splash.png',
          height: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
