import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civexam_app/screens/official_intro_screen.dart';
import 'package:civexam_app/screens/multi_exam_flow.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  ByteData _stringToByteData(String value) {
    final list = utf8.encode(value);
    final buffer = Uint8List.fromList(list).buffer;
    return ByteData.view(buffer);
  }

  setUp(() {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key == 'assets/questions/civexam_questions_ena_core.json') {
        final sample = '[{"id":"Q1","concours":"ENA","subject":"S","chapter":"C","difficulty":1,"question":"Q?","choices":["A","B"],"answerIndex":0}]';
        return _stringToByteData(sample);
      }
      return null;
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('navigates to MultiExamFlow after countdown', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OfficialIntroScreen()));

    // Accept rules
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Start countdown
    await tester.tap(find.text('Démarrer la simulation officielle'));
    await tester.pump();

    // Wait for countdown to finish
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(MultiExamFlowScreen), findsOneWidget);
  });
}
