import 'dart:async';
import 'package:flutter/material.dart';

import 'play_screen.dart';

/// Splash simple qui redirige TOUJOURS vers le PlayScreen mosaïque (nouvelle UI).
/// - Pas de routes nommées héritées, pas de dépendances exotiques.
class SplashAnimated extends StatefulWidget {
  final Widget next;
  const SplashAnimated({super.key, this.next = const PlayScreen()});

  @override
  State<SplashAnimated> createState() => _SplashAnimatedState();
}

class _SplashAnimatedState extends State<SplashAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    _c.forward();

    // ⏱️ Après 1.6s, on remplace l'écran par le PlayScreen mosaïque
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => widget.next,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4B60CC), Color(0xFF5A6ED6)],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // ✅ Carré (plus de masque en cercle)
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png', // assure-toi que le chemin est correct
                width: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
