import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civexam_pro/screens/chapter_list_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ChapterListScreen uses themed hierarchy for settings and info', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ChapterListScreen(subjectName: 'Test', chapterName: 'Module'),
    ));

    await tester.pump();
    for (int i = 0; i < 10; i++) {
      if (tester.any(find.text('Temps par question'))) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    final BuildContext headingContext = tester.element(find.text('Temps par question'));
    final textTheme = Theme.of(headingContext).textTheme;

    final Text moduleHeading = tester.widget(find.text('Module : Module'));
    expect(moduleHeading.style, textTheme.titleLarge);

    final Text timeHeading = tester.widget(find.text('Temps par question'));
    expect(timeHeading.style, textTheme.titleMedium);

    final Text countHeading = tester.widget(find.text('Nombre de questions'));
    expect(countHeading.style, textTheme.titleMedium);

    final Text availability = tester.widget(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data != null && widget.data!.startsWith('Questions dispo pour ce module'),
      ),
    );
    expect(availability.style, textTheme.bodyLarge);
  });
}
