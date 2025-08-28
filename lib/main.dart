import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app/theme.dart';
import 'firebase_options.dart';
import 'screens/play_screen.dart';
import 'screens/login_screen.dart';
import 'services/design_prefs.dart';
import 'services/design_bus.dart';
import 'widgets/design_background.dart';
import 'models/design_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final cfg = await DesignPrefs.load();
  DesignBus.push(cfg);
  runApp(const CivExamApp());
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
          theme: buildAppTheme(cfg, Brightness.light),
          darkTheme: buildAppTheme(cfg, Brightness.dark),
          themeMode: ThemeMode.system,
          builder: (context, child) => DesignBackground(child: child ?? const SizedBox()),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return const PlayScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
