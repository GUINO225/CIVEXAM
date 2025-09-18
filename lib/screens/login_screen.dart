import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final errorStyle = TextStyle(color: colorScheme.error);
        final isBusy = _isLoading || _isGoogleLoading;
        final panelOpacity = cfg.darkMode ? 0.88 : 0.94;
        final panelColor = colorScheme.surface.withOpacity(panelOpacity);
        final shadowColor =
            Colors.black.withOpacity(cfg.darkMode ? 0.6 : 0.18);
        final appBarColor =
            colorScheme.surface.withOpacity(cfg.darkMode ? 0.85 : 0.9);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: appBarColor,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            title: Text(_isLogin ? 'Se connecter' : "Créer un compte"),
            titleTextStyle:
                theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 32,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo_splash.png',
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),
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
                              final emailRegex =
                                  RegExp(r'^[^@]+@[^@]+[.][^@]+$');
                              if (!emailRegex.hasMatch(email)) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          if (!_isLogin)
                            ...[
                              TextFormField(
                                controller: _nameController,
                                decoration:
                                    const InputDecoration(labelText: 'Nom'),
                                validator: (value) {
                                  if (!_isLogin &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Nom requis';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                                labelText: 'Mot de passe'),
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
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(_isLogin ? 'Connexion' : 'Inscription'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: isBusy ? null : _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4285F4),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Colors.black.withOpacity(0.25),
                            ),
                            icon: _isGoogleLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    FontAwesomeIcons.google,
                                    size: 24,
                                  ),
                            label: const Text('Se connecter avec Google'),
                          ),
                          const SizedBox(height: 12),
                          if (_unverifiedUser != null)
                            TextButton(
                              onPressed: _resendVerificationEmail,
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                              ),
                              child: const Text(
                                  'Renvoyer l\'email de vérification'),
                            ),
                          TextButton(
                            onPressed: () => setState(() {
                              _isLogin = !_isLogin;
                              _unverifiedUser = null;
                            }),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                            ),
                            child: Text(
                                _isLogin ? "Créer un compte" : 'Déjà inscrit ?'),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
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
