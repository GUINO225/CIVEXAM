import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  bool _isGoogleLoading = false;
  User? _unverifiedUser;

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
        final isBusy = _isLoading || _isGoogleLoading;
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
                    onPressed: isBusy ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isLogin ? 'Connexion' : 'Inscription'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isBusy ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            FontAwesomeIcons.google,
                            color: Color(0xFF4285F4),
                          ),
                    label: const Text('Continuer avec Google'),
                  ),
                  const SizedBox(height: 12),
                  if (_unverifiedUser != null)
                    TextButton(
                      onPressed: _resendVerificationEmail,
                      child: const Text('Renvoyer l\'email de vérification'),
                    ),
                  TextButton(
                    onPressed: () => setState(() {
                      _isLogin = !_isLogin;
                      _unverifiedUser = null;
                    }),
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _error = null;
      _isGoogleLoading = true;
      _unverifiedUser = null;
    });
    try {
      if (!kIsWeb) {
        try {
          await GoogleSignIn().signOut();
        } catch (_) {}
      }
      final credential = await _auth.signInWithGoogle();
      if (!mounted) return;
      if (credential.user == null) {
        setState(() => _error = 'Connexion Google impossible');
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PlayScreen()),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Une erreur inattendue est survenue');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _isLoading = true;
      _unverifiedUser = null;
    });
    try {
      UserCredential credential;
      if (_isLogin) {
        credential = await _auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        credential = await _auth.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      }
      final user = credential.user;
      if (user != null && !user.emailVerified) {
        if (mounted) {
          setState(() {
            _error = 'Veuillez vérifier votre email';
            _unverifiedUser = user;
          });
        }
        return;
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

  Future<void> _resendVerificationEmail() async {
    final user = _unverifiedUser;
    if (user != null) {
      try {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email de vérification envoyé')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Envoi de l\'email impossible')),
          );
        }
      }
    }
  }
}
