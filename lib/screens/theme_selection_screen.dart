import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/design_prefs.dart';
import '../utils/palette_utils.dart';

/// Simple screen that lets the user choose among the 7 rainbow palettes
/// and toggle light/dark mode. The choice is persisted via [DesignPrefs]
/// and pushed through [DesignBus] for live updates.
class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
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
    DesignBus.push(c);
  }

  Future<void> _apply(DesignConfig c) async {
    setState(() => _cfg = c);
    DesignBus.push(c);
    await DesignPrefs.save(c);
  }

  Future<void> _select(String name) async {
    final updated = _cfg.useMono
        ? _cfg.copyWith(
            bgPaletteName: name,
            monoColor: complementaryColor(name),
          )
        : _cfg.copyWith(bgPaletteName: name);
    await _apply(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un thème')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in [
                'offWhite',
                'lightGrey',
                'darkGrey',
                'pastelBlue',
                'powderPink',
                'lightGreen',
                'softYellow',
                'midnightBlue',
                'anthracite',
                'blueIndigo',
                'violetRose',
                'mintTurquoise',
                'deepBlack',
                'sereneBlue',
                'forestGreen',
                'deepIndigo',
                'royalViolet',
              ])
                _paletteChip(name, _cfg.bgPaletteName == name),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: _cfg.darkMode,
            onChanged: (v) => _apply(_cfg.copyWith(darkMode: v)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  Widget _paletteChip(String name, bool selected) {
    final colors = pastelColors(name, darkMode: _cfg.darkMode);
    final textColor = textColorForPalette(name, darkMode: _cfg.darkMode);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _select(name),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? textColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(name, style: TextStyle(color: textColor)),
        ),
      ),
    );
  }
}
