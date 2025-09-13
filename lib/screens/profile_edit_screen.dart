import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _professionController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final profile = await UserProfileService().fetch(uid);
      if (profile != null) {
        _nicknameController.text = profile.nickname;
        _professionController.text = profile.profession;
      }
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = UserProfile(
      nickname: _nicknameController.text.trim(),
      profession: _professionController.text.trim(),
    );
    await UserProfileService().save(profile);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(labelText: 'Surnom'),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.length < 3) {
                          return 'Au moins 3 caractères';
                        }
                        if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(value)) {
                          return 'Caractères non autorisés';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _professionController,
                      decoration: const InputDecoration(labelText: 'Profession'),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.length < 3) {
                          return 'Au moins 3 caractères';
                        }
                        if (!RegExp(r'^[A-Za-zÀ-ÿ\s-]+$').hasMatch(value)) {
                          return 'Caractères non autorisés';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
