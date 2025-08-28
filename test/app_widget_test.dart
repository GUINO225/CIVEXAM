import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:civexam_app/firebase_options.dart';
import 'package:civexam_app/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  testWidgets('CivExamApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const CivExamApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
