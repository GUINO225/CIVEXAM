import 'package:flutter/material.dart';
import 'app/theme.dart';
import 'screens/play_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CivExamApp());
}

class CivExamApp extends StatelessWidget {
  const CivExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CivExam',
      theme: buildAppTheme(),
      home: const PlayScreen(), // ✅ démarre sur PlayScreen (dashboard)
    );
  }
}
