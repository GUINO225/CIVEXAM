import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civexam_pro/screens/training_quick_start.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TrainingQuickStartScreen uses themed hierarchy for settings and summary', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TrainingQuickStartScreen(),
    ));

    await tester.pump();

    final BuildContext headingContext = tester.element(find.text('Temps par question'));
    final textTheme = Theme.of(headingContext).textTheme;

    final Text timeHeading = tester.widget(find.text('Temps par question'));
    expect(timeHeading.style, textTheme.titleMedium);

    final Text countHeading = tester.widget(find.text('Nombre de questions'));
    expect(countHeading.style, textTheme.titleMedium);

    final Text summary = tester.widget(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data != null && widget.data!.startsWith('Temps total'),
      ),
    );
    expect(summary.style, textTheme.bodyLarge);
  });
}
