import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/auth_service.dart';
import '../services/design_bus.dart';
import '../widgets/primary_button.dart';
import 'play_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final errorStyle = TextStyle(color: Theme.of(context).colorScheme.error);
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar:
              AppBar(title: Text(_isLogin ? 'Se connecter' : "Créer un compte")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email requis';
                      }
                      final email = value.trim();
                      final emailRegex = RegExp(r'^[^@]+@[^@]+[.][^@]+$');
                      if (!emailRegex.hasMatch(email)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (value) {
                        if (!_isLogin &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Nom requis';
                        }
                        return null;
                      },
                    ),
                  TextFormField(
                    controller: _passwordController,
                    decoration:
                        const InputDecoration(labelText: 'Mot de passe'),
                    keyboardType: TextInputType.visiblePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: true,
                    validator: (value) {
                      final pwd = value?.trim() ?? '';
                      if (pwd.isEmpty) {
                        return 'Mot de passe requis';
                      }
                      if (pwd.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      final hasLetter = RegExp(r'[A-Za-z]').hasMatch(pwd);
                      final hasDigit = RegExp(r'\d').hasMatch(pwd);
                      if (!hasLetter || !hasDigit) {
                        return 'Le mot de passe doit contenir des lettres et des chiffres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: errorStyle),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isLogin ? 'Connexion' : 'Inscription'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                        _isLogin ? "Créer un compte" : 'Déjà inscrit ?'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _isLoading = true;
    });
    try {
      if (_isLogin) {
        await _auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _auth.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PlayScreen()),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Une erreur inattendue est survenue');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
