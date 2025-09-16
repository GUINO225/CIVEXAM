import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/theme.dart';
import 'firebase_options.dart';
import 'services/design_prefs.dart';
import 'services/design_bus.dart';
import 'widgets/design_background.dart';
import 'models/design_config.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(
    () => runApp(const CivExamApp()),
    (error, stack) {
      debugPrint('Uncaught async error: $error\n$stack');
    },
  );
}

class CivExamApp extends StatefulWidget {
  const CivExamApp({super.key});

  @override
  State<CivExamApp> createState() => _CivExamAppState();
}

class _CivExamAppState extends State<CivExamApp> {
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseFirestore.instance.settings =
          const Settings(persistenceEnabled: true);
      final cfg = await DesignPrefs.load();
      DesignBus.push(cfg);
    } catch (error, stackTrace) {
      debugPrint('App initialization failed: $error\n$stackTrace');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorApp(error: snapshot.error);
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingApp();
        }

        return const _CivExamConfiguredApp();
      },
    );
  }
}

class _CivExamConfiguredApp extends StatelessWidget {
  const _CivExamConfiguredApp();

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

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement en cours...'),
            ],
          ),
        ),
      ),
    );
  }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text('Une erreur est survenue lors du démarrage.'),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text('$error'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
