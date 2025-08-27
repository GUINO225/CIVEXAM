import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/duel_service.dart';

class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key});

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  final _service = DuelService();
  String? _duelId;
  final _joinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duels')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _createDuel,
              child: const Text('Créer un duel'),
            ),
            if (_duelId != null)
              Text('ID du duel: $_duelId'),
            const SizedBox(height: 24),
            TextField(
              controller: _joinController,
              decoration: const InputDecoration(labelText: 'ID duel à rejoindre'),
            ),
            ElevatedButton(
              onPressed: _joinDuel,
              child: const Text('Rejoindre'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDuel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final id = await _service.createDuel(user.uid);
    setState(() => _duelId = id);
  }

  Future<void> _joinDuel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _service.joinDuel(_joinController.text.trim(), user.uid);
    setState(() => _duelId = _joinController.text.trim());
  }
}
