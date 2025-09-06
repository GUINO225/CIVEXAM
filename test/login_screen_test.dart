import 'package:civexam_app/firebase_options.dart';
import 'package:civexam_app/screens/login_screen.dart';
import 'package:civexam_app/widgets/primary_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('rejects invalid emails', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'invalid',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mot de passe'),
      'password123',
    );
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(find.text('Email invalide'), findsOneWidget);
  });
}
