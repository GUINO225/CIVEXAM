// lib/screens/design_settings_screen.dart
// Page de personnalisation inspirée du design violet illustré par le client.
// Se concentre sur un aperçu immersif et la sélection de la palette de couleurs.

import 'dart:async';

import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/design_prefs.dart';
import '../utils/palette_utils.dart';

class DesignSettingsScreen extends StatefulWidget {
  const DesignSettingsScreen({super.key});

  @override
  State<DesignSettingsScreen> createState() => _DesignSettingsScreenState();
}

class _DesignSettingsScreenState extends State<DesignSettingsScreen> {
  DesignConfig _cfg = const DesignConfig();

  // Palettes proposées (tons épurés et contrastes soignés)
  static const List<String> _palettes = [
    'civFlag',
    'navyCyanAmber',
    'indigoPurpleSky',
    'emeraldTealMint',
    'royalBlueGold',
    'charcoalElectric',
    'forestSandTerracotta',
    'cobaltLimeSlate',
    'calmPastels',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await DesignPrefs.load();
    if (!mounted) return;
    setState(() => _cfg = c);
    // Propager l'état actuel pour les autres widgets.
    DesignBus.push(c);
  }

  void _apply(DesignConfig c) {
    setState(() => _cfg = c);
    DesignBus.push(c); // mise à jour en direct
    unawaited(() async {
      try {
        await DesignPrefs.save(c); // persistance
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de sauvegarder')),
        );
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = accentColor(_cfg.bgPaletteName);
    final accentDarker = darkerAccentColor(_cfg.bgPaletteName, 0.18);
    final onAccent = onColor(accent);
    final backgroundGradient =
        pastelColors(_cfg.bgPaletteName, darkMode: _cfg.darkMode);
    final backgroundColor =
        Color.lerp(Colors.white, backgroundGradient.last, 0.9) ??
            backgroundGradient.last;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Fermer',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: accent,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personnalisation',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choisis la palette qui correspond à ton énergie du moment.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accent.withOpacity(0.18),
                    child: Icon(
                      Icons.color_lens_rounded,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Palettes disponibles',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                itemCount: _palettes.length,
                itemBuilder: (context, index) => _paletteCircle(_palettes[index]),
              ),
              const SizedBox(height: 32),
              _buildPreviewHero(
                accent: accent,
                accentDarker: accentDarker,
                onAccent: onAccent,
                paletteLabel: _readablePalette(_cfg.bgPaletteName),
                textTheme: textTheme,
              ),
              const SizedBox(height: 40),
              Center(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: onAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    textStyle: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Appliquer et revenir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paletteCircle(String name) {
    final accent = accentColor(name);
    final highlight = darkerAccentColor(name, 0.16);
    final selected = _cfg.bgPaletteName == name;
    final label = _readablePalette(name);
    final textColor = onColor(accent);

    return Semantics(
      label: 'Palette $label',
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            final updated = _cfg.useMono
                ? _cfg.copyWith(
                    bgPaletteName: name,
                    monoColor: complementaryColor(name),
                  )
                : _cfg.copyWith(bgPaletteName: name);
            _apply(updated);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [accent, highlight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: selected
                        ? textColor.withOpacity(0.9)
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: highlight.withOpacity(selected ? 0.35 : 0.14),
                      blurRadius: selected ? 20 : 14,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: selected ? 1 : 0,
                  child: Icon(
                    Icons.check_rounded,
                    color: textColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(selected ? 0.85 : 0.6),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewHero({
    required Color accent,
    required Color accentDarker,
    required Color onAccent,
    required String paletteLabel,
    required TextTheme textTheme,
  }) {
    final overlay = Colors.white.withOpacity(0.16);
    final highlight = Colors.white.withOpacity(0.22);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accentDarker],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: accentDarker.withOpacity(0.28),
            blurRadius: 36,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APERÇU EN DIRECT',
            style: textTheme.labelLarge?.copyWith(
              color: onAccent.withOpacity(0.75),
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            paletteLabel,
            style: textTheme.headlineMedium?.copyWith(
              color: onAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ton interface se met immédiatement aux couleurs sélectionnées.',
            style: textTheme.bodyMedium?.copyWith(
              color: onAccent.withOpacity(0.78),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: overlay,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quiz récent',
                            style: textTheme.titleMedium?.copyWith(
                              color: onAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quiz Culture Générale',
                            style: textTheme.bodyMedium?.copyWith(
                              color: onAccent.withOpacity(0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 72,
                      width: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 0.65,
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(onAccent),
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                          Text(
                            '65%',
                            style: textTheme.titleMedium?.copyWith(
                              color: onAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: highlight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.24),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          color: onAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Défis entre amis',
                              style: textTheme.titleSmall?.copyWith(
                                color: onAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lance un challenge en quelques secondes.',
                              style: textTheme.bodySmall?.copyWith(
                                color: onAccent.withOpacity(0.78),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: onAccent,
                          foregroundColor: accent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Inviter'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quiz en direct',
                  style: textTheme.titleSmall?.copyWith(
                    color: onAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Column(
                  children: [
                    _previewListTile(
                      icon: Icons.calculate_outlined,
                      title: 'Statistiques Math Quiz',
                      subtitle: '10 questions',
                      onAccent: onAccent,
                    ),
                    const SizedBox(height: 12),
                    _previewListTile(
                      icon: Icons.numbers_rounded,
                      title: 'Quiz Aptitude Numérique',
                      subtitle: '8 questions',
                      onAccent: onAccent,
                    ),
                    const SizedBox(height: 12),
                    _previewListTile(
                      icon: Icons.psychology_alt_outlined,
                      title: 'Organisation & Logique',
                      subtitle: '12 questions',
                      onAccent: onAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color onAccent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: onAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: onAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: onAccent.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: onAccent.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  String _readablePalette(String name) {
    final spaced = name
        .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (m) => ' ')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
    final parts = spaced.split(' ').where((part) => part.isNotEmpty);
    return parts
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }
}

