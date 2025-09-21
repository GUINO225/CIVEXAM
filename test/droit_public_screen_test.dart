import 'dart:async';

import 'package:civexam_pro/screens/courses/droit_public_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DroitPublicScreen affiche les sections Constitution et Administration',
      (WidgetTester tester) async {
    const sections = [
      DroitPublicSection(
        title: 'Constitution',
        description: 'Principes fondamentaux.',
        highlights: ['Hiérarchie des normes'],
      ),
      DroitPublicSection(
        title: 'Administration',
        description: 'Organisation des services.',
        highlights: ['Contrôles administratifs'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: DroitPublicScreen(
          sectionsFuture: Future<List<DroitPublicSection>>.value(sections),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Constitution'), findsOneWidget);
    expect(find.text('Administration'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
  });
}
