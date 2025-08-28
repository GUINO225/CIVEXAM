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
          theme: buildAppTheme(cfg),
          builder: (context, child) =>
              DesignBackground(child: child ?? const SizedBox()),
          home: const SplashScreen(),
        );
      },
    );
  }
}
