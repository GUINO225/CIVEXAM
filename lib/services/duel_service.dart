import 'package:cloud_firestore/cloud_firestore.dart';

class DuelService {
  final _duels = FirebaseFirestore.instance.collection('duels');

  Future<String> createDuel(String userId) async {
    final doc = await _duels.add({
      'player1': userId,
      'player2': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> joinDuel(String duelId, String userId) async {
    await _duels.doc(duelId).update({'player2': userId});
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDuel(String duelId) {
    return _duels.doc(duelId).snapshots();
  }
}
