import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:civexam_app/services/competition_service.dart';
import 'package:mocktail/mocktail.dart';

class FailingCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  @override
  Query<Map<String, dynamic>> orderBy(String field,
          {bool descending = false}) =>
      this;

  @override
  Query<Map<String, dynamic>> limit(int limit) => this;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) {
    throw FirebaseException(
        plugin: 'firestore', code: 'unavailable', message: 'network');
  }
}

void main() {
  test('topEntries rethrows Firestore errors', () async {
    final service = CompetitionService(col: FailingCollectionReference());
    expect(service.topEntries(), throwsA(isA<FirebaseException>()));
  });
}
