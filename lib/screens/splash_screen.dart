import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'play_screen.dart';

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
      final User? user = await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      final next = user == null ? const LoginScreen() : const PlayScreen();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => next),
      );
    } on TimeoutException {
      _goToLogin(
          'La connexion a expiré. Veuillez vous reconnecter.');
    } catch (_) {
      _goToLogin('Connexion impossible. Veuillez vous reconnecter.');
    }
  }

  void _goToLogin(String message) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/logo_splash.png'),
          width: 200,
        ),
      ),
    );
  }
}
