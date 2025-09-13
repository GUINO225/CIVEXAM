import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civexam_app/models/leaderboard_entry.dart';
import 'package:civexam_app/screens/dashboard_screen.dart';
import 'package:civexam_app/services/competition_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

class DummyCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {}

class FakeCompetitionService extends CompetitionService {
  FakeCompetitionService() : super(col: DummyCollectionReference());

  @override
  Stream<List<LeaderboardEntry>> topEntriesStream({int limit = 100}) {
    return Stream.error(Exception('network'));
  }
}

void main() {
  testWidgets('shows error message when stream fails', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DashboardScreen(service: FakeCompetitionService()),
    ));

    // allow stream to emit the error
    await tester.pump();

    expect(find.text('Erreur de chargement du classement'), findsOneWidget);
  });
}
