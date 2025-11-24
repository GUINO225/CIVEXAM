import 'package:flutter/material.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import 'training_quick_start.dart';

class GuestPreviewScreen extends StatelessWidget {
  const GuestPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final textColor =
            textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);
        final secondaryColor = Theme.of(context).colorScheme.secondary;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: textColor,
            title: const Text('Mode invité'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo_splash.png',
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Essayez CivExam en mode invité',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Accès limité : seul un quiz de démonstration est disponible. '
                    'Connectez-vous ou créez un compte pour débloquer toutes les '
                    'fonctionnalités.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fonctionnalités complètes après connexion :',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          ...const [
                            '• Dashboard et progression détaillée',
                            '• Classements et défis',
                            '• Historique des examens',
                            '• Profil et préférences synchronisées',
                          ].map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(item),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrainingQuickStartScreen(),
                        ),
                      );
                    },
                    child: const Text('Lancer le quiz de test'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: Icon(Icons.lock_open, color: secondaryColor),
                    label: const Text('Se connecter pour tout débloquer'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
