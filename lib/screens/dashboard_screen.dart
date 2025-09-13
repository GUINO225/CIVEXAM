import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LeaderboardEntry? _entry;
  int? _rank;
  bool _loading = true;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final entries = await CompetitionService().topEntries(limit: 1000);
    final index = entries.indexWhere((e) => e.userId == uid);
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!mounted) return;
    setState(() {
      _entry = index >= 0 ? entries[index] : null;
      _rank = index >= 0 ? index + 1 : null;
      _photoUrl = userDoc.data()?['photoUrl'] as String?;
      _loading = false;
    });
  }

  Future<void> _pickAndUpload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final ref = FirebaseStorage.instance.ref().child('user_photos/$uid.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'photoUrl': url}, SetOptions(merge: true));
    if (!mounted) return;
    setState(() => _photoUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entry == null
              ? const Center(child: Text('Aucune donnée de compétition'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickAndUpload,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                            child: _photoUrl == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Nom : ${_entry!.name}',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                          'Score : ${_entry!.percent.toStringAsFixed(1)}% (${_entry!.correct}/${_entry!.total})'),
                      const SizedBox(height: 8),
                      if (_rank != null)
                        Text('Classement global : $_rank'),
                    ],
                  ),
                ),
    );
  }
}
