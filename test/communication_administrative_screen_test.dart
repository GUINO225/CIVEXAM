import 'dart:async';

import 'package:civexam_pro/screens/courses/communication_administrative_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'CommunicationAdministrativeScreen affiche les sections fournies',
    (WidgetTester tester) async {
      const sections = [
        CommunicationAdministrativeSection(
          title: 'Principes',
          description: 'Règles de base.',
          highlights: ['Clarté', 'Traçabilité'],
        ),
        CommunicationAdministrativeSection(
          title: 'Communication écrite',
          description: 'Méthodologie.',
          highlights: ['Structure', 'Relecture'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CommunicationAdministrativeScreen(
            sectionsFuture:
                Future<List<CommunicationAdministrativeSection>>.value(
              sections,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Principes'), findsOneWidget);
      expect(find.text('Communication écrite'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
    },
  );

  test(
    'CommunicationAdministrativeRepository charge les sections depuis l\'asset',
    () async {
      final sections =
          await const CommunicationAdministrativeRepository().loadSections();
      expect(sections, isNotEmpty);
      expect(sections.first.title, isNotEmpty);
    },
  );
}
