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
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      final next = user == null ? const LoginScreen() : const PlayScreen();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => next),
      );
    });
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
