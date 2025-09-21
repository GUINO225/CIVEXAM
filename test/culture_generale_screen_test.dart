import 'dart:async';

import 'package:civexam_pro/screens/courses/culture_generale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CultureGeneraleScreen affiche les sections CI et Afrique',
      (WidgetTester tester) async {
    const sections = [
      CultureSection(
        title: 'Côte d’Ivoire',
        description: 'Repères nationaux.',
        highlights: ['Institutions', 'Économie'],
      ),
      CultureSection(
        title: 'Afrique',
        description: 'Repères continentaux.',
        highlights: ['Organisations régionales'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: CultureGeneraleScreen(
          sectionsFuture: Future<List<CultureSection>>.value(sections),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Côte d’Ivoire'), findsOneWidget);
    expect(find.text('Afrique'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
  });
}
