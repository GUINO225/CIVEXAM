// lib/screens/design_settings_screen.dart
import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/design_prefs.dart';
import '../services/design_bus.dart';

class DesignSettingsScreen extends StatefulWidget {
  const DesignSettingsScreen({super.key});

  @override
  State<DesignSettingsScreen> createState() => _DesignSettingsScreenState();
}

class _DesignSettingsScreenState extends State<DesignSettingsScreen> {
  DesignConfig _cfg = const DesignConfig();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await DesignPrefs.load();
    if (!mounted) return;
    setState(() => _cfg = c);
    // pousser l’état actuel vers le bus (au cas où)
    DesignBus.push(c);
  }

  Future<void> _apply(DesignConfig c) async {
    setState(() => _cfg = c);
    DesignBus.push(c);            // 🔴 live update
    await DesignPrefs.save(c);    // 💾 persistance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages design')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Palette de fond', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _paletteChip('blueRoyal', _cfg.bgPaletteName == 'blueRoyal'),
              _paletteChip('blueAqua', _cfg.bgPaletteName == 'blueAqua'),
              _paletteChip('midnight', _cfg.bgPaletteName == 'midnight'),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Effet “wave” (halo)'),
            value: _cfg.waveEnabled,
            onChanged: (v) => _apply(_cfg.copyWith(waveEnabled: v)),
          ),
          const Divider(height: 32),

          const Text('Verre (glassmorphism)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _sliderTile(
            label: 'Blur',
            value: _cfg.glassBlur,
            min: 8, max: 28, divisions: 20,
            onChanged: (v) => _apply(_cfg.copyWith(glassBlur: v)),
          ),
          _sliderTile(
            label: 'Opacité fond (verre)',
            value: _cfg.glassBgOpacity,
            min: 0.08, max: 0.30, divisions: 22,
            onChanged: (v) => _apply(_cfg.copyWith(glassBgOpacity: v)),
          ),
          _sliderTile(
            label: 'Opacité bordure (verre)',
            value: _cfg.glassBorderOpacity,
            min: 0.0, max: 0.5, divisions: 25,
            onChanged: (v) => _apply(_cfg.copyWith(glassBorderOpacity: v)),
          ),
          const Divider(height: 32),

          const Text('Tuiles', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _sliderTile(
            label: 'Taille icône (px)',
            value: _cfg.tileIconSize,
            min: 36, max: 76, divisions: 40,
            onChanged: (v) => _apply(_cfg.copyWith(tileIconSize: v)),
          ),
          SwitchListTile(
            title: const Text('Centrer icône + texte'),
            value: _cfg.tileCenter,
            onChanged: (v) => _apply(_cfg.copyWith(tileCenter: v)),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  Widget _paletteChip(String name, bool selected) {
    return ChoiceChip(
      label: Text(name),
      selected: selected,
      onSelected: (_) => _apply(_cfg.copyWith(bgPaletteName: name)),
    );
  }

  Widget _sliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          value: value, min: min, max: max, divisions: divisions,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
