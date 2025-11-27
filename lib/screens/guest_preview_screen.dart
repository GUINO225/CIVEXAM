import 'package:flutter/material.dart';

import 'cycle_selection_screen.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import 'training_quick_start.dart';

class _GuestFeature {
  final String title;
  final String description;
  final IconData icon;
  final bool enabled;

  const _GuestFeature({
    required this.title,
    required this.description,
    required this.icon,
    this.enabled = false,
  });
}

class GuestPreviewScreen extends StatelessWidget {
  const GuestPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CycleSelectionScreen(guestMode: true);
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final textColor =
            textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);
        final secondaryColor = Theme.of(context).colorScheme.secondary;
        final disabledColor = Theme.of(context)
            .colorScheme
            .onSurface
            .withOpacity(cfg.darkMode ? 0.35 : 0.45);

        final features = <_GuestFeature>[
          const _GuestFeature(
            title: 'Quiz rapide',
            description: 'Un quiz d\'entraînement immédiat pour tester l\'app.',
            icon: Icons.flash_on_rounded,
            enabled: true,
          ),
          const _GuestFeature(
            title: 'Examens complets',
            description: 'Sessions chronométrées, statistiques détaillées.',
            icon: Icons.assignment_turned_in_rounded,
          ),
          const _GuestFeature(
            title: 'Mode Arcade',
            description: 'Défis rapides avec progression et badges.',
            icon: Icons.videogame_asset_rounded,
          ),
          const _GuestFeature(
            title: 'Classements',
            description: 'Comparez vos scores et défiez vos amis.',
            icon: Icons.emoji_events_rounded,
          ),
          const _GuestFeature(
            title: 'Historique & suivi',
            description: 'Reprenez vos sessions et suivez vos progrès.',
            icon: Icons.timeline_rounded,
          ),
          const _GuestFeature(
            title: 'Profil & préférences',
            description: 'Sauvegarde cloud, thèmes et paramètres.',
            icon: Icons.person_rounded,
          ),
        ];

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
                  _FeatureGrid(
                    features: features,
                    textColor: textColor,
                    disabledColor: disabledColor,
                    onLaunchQuickQuiz: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrainingQuickStartScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: secondaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Envie de tout débloquer ?',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Créez un compte ou connectez-vous pour accéder aux examens, '
                            'classements, suivi complet et synchronisation cloud.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: textColor.withOpacity(0.9),
                                ),
                          ),
                          const SizedBox(height: 12),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Text(item),
                            ),
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TrainingQuickStartScreen(),
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
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.lock_open, color: secondaryColor),
                            label: const Text(
                              'Se connecter pour tout débloquer',
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({
    required this.features,
    required this.textColor,
    required this.disabledColor,
    required this.onLaunchQuickQuiz,
  });

  final List<_GuestFeature> features;
  final Color textColor;
  final Color disabledColor;
  final VoidCallback onLaunchQuickQuiz;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fonctionnalités visibles en mode invité',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: textColor),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            final isEnabled = feature.enabled;
            final cardContent = _FeatureCard(
              feature: feature,
              textColor: textColor,
              disabledColor: disabledColor,
              onTap: isEnabled ? onLaunchQuickQuiz : null,
            );
            return isEnabled ? cardContent : _LockedOverlay(child: cardContent);
          },
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.textColor,
    required this.disabledColor,
    this.onTap,
  });

  final _GuestFeature feature;
  final Color textColor;
  final Color disabledColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).cardColor;
    final enabled = feature.enabled;
    return Material(
      color: enabled ? base : base.withOpacity(0.75),
      elevation: enabled ? 2 : 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: enabled
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.12)
                      : disabledColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature.icon,
                  size: 28,
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : disabledColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: enabled ? textColor : disabledColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: enabled
                          ? textColor.withOpacity(0.9)
                          : disabledColor,
                    ),
              ),
              if (enabled) ...[
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Accéder',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.9,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Theme.of(context)
                  .colorScheme
                  .surfaceVariant
                  .withOpacity(0.45),
              BlendMode.srcATop,
            ),
            child: child,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connectez-vous pour y accéder',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
