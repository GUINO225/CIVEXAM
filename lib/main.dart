import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/theme.dart';
import 'firebase_options.dart';
import 'services/design_prefs.dart';
import 'services/design_bus.dart';
import 'widgets/design_background.dart';
import 'models/design_config.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runZonedGuarded<Future<void>>(() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      final cfg = await DesignPrefs.load();
      DesignBus.push(cfg);
      runApp(const CivExamApp());
    } catch (e, st) {
      debugPrint('App initialization failed: $e\n$st');
      runApp(ErrorApp(error: e));
    }
  }, (error, stack) {
    debugPrint('Uncaught async error: $error\n$stack');
  });
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Une erreur est survenue: $error'),
        ),
      ),
    );
  }
}

class CivExamApp extends StatelessWidget {
  const CivExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CivExam',
          theme: buildAppTheme(cfg),
          builder: (context, child) =>
              DesignBackground(child: child ?? const SizedBox()),
          home: const SplashScreen(),
        );
      },
    );
  }
}
