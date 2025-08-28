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
            spacing: 8,
            runSpacing: 8,
            children: [
              _paletteChip('coteIvoire', _cfg.bgPaletteName == 'coteIvoire'),
              _paletteChip('senegal', _cfg.bgPaletteName == 'senegal'),
              _paletteChip('ghana', _cfg.bgPaletteName == 'ghana'),
              _paletteChip('nigeria', _cfg.bgPaletteName == 'nigeria'),
              _paletteChip('kenya', _cfg.bgPaletteName == 'kenya'),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Effet “wave” (halo)'),
            value: _cfg.waveEnabled,
            onChanged: (v) => _apply(_cfg.copyWith(waveEnabled: v)),
          ),
          const SizedBox(height: 16),
          const Text('Icônes', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Icônes monochromes'),
            value: _cfg.useMono,
            onChanged: (v) => _apply(_cfg.copyWith(useMono: v)),
          ),
          if (_cfg.useMono)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconColorsForPalette(_cfg.bgPaletteName)
                  .map((c) => _colorChip(c, _cfg.monoColor == c))
                  .toList(),
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

  List<Color> _iconColorsForPalette(String name) {
    switch (name) {
      case 'coteIvoire':
        return const [Colors.white, Color(0xFFFF8C00), Color(0xFF00C851)];
      case 'senegal':
        return const [Colors.white, Color(0xFF00853F), Color(0xFFEF2B2D)];
      case 'ghana':
        return const [Colors.white, Color(0xFFE21B1B), Color(0xFF006B3F)];
      case 'nigeria':
        return const [Colors.white, Color(0xFF008751), Color(0xFFA7FF83)];
      case 'kenya':
        return const [Colors.white, Color(0xFFBB1919), Color(0xFF006600)];
      case 'blueAqua':
        return const [Colors.white, Color(0xFF6C8BF5), Color(0xFF3A4CC5)];
      case 'midnight':
        return const [Colors.white, Color(0xFF2C5364), Color(0xFF0F2027)];
      case 'sunset':
        return const [Colors.white, Color(0xFFFF9966), Color(0xFFFF5E62)];
      case 'forest':
        return const [Colors.white, Color(0xFF2F7336), Color(0xFFAAFFA9)];
      case 'ocean':
        return const [Colors.white, Color(0xFF1A2980), Color(0xFF26D0CE)];
      case 'fire':
        return const [Colors.white, Color(0xFFFF512F), Color(0xFFF09819)];
      case 'purple':
        return const [Colors.white, Color(0xFF2A0845), Color(0xFF6441A5)];
      case 'pink':
        return const [Colors.white, Color(0xFFFF9A9E), Color(0xFFFAD0C4)];
      case 'emerald':
        return const [Colors.white, Color(0xFF00B09B), Color(0xFF96C93D)];
      case 'candy':
        return const [Colors.white, Color(0xFFF857A6), Color(0xFFFF5858)];
      case 'steel':
        return const [Colors.white, Color(0xFF232526), Color(0xFF414345)];
      case 'coffee':
        return const [Colors.white, Color(0xFF603813), Color(0xFFB29F94)];
      case 'gold':
        return const [Colors.white, Color(0xFFF6D365), Color(0xFFFDA085)];
      case 'lavender':
        return const [Colors.white, Color(0xFFB993D6), Color(0xFF8CA6DB)];
      case 'blueRoyal':
      default:
        return const [Colors.white, Color(0xFF37478F), Color(0xFF0D1E42)];
    }
  }

  Widget _colorChip(Color color, bool selected) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return ChoiceChip(
      label: const SizedBox(width: 24, height: 24),
      selected: selected,
      selectedColor: color,
      backgroundColor: color,
      checkmarkColor: brightness == Brightness.dark ? Colors.white : Colors.black,
      onSelected: (_) => _apply(_cfg.copyWith(monoColor: color)),
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
