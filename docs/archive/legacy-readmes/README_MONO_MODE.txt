CivExam — Mono Mode Color Fix Patch
But: En mode "Icônes monochromes", les icônes restaient blanches.
Actions:
- Default monoColor fixé à AMBER (0xFFFF7A00) dans DesignConfig (plus jamais blanc par défaut)
- DesignPrefs charge/sauvegarde correctement monoColor (int ARGB)
- DesignSettings propose des pastilles de couleur mono pour changer en 1 tap

Étapes:
1) Copier ces 3 fichiers dans votre projet:
   - lib/models/design_config.dart
   - lib/services/design_prefs.dart
   - lib/screens/design_settings_screen.dart
2) Redémarrer proprement: flutter clean && flutter pub get && flutter run
3) Dans l'app: activez "Icônes monochromes" et choisissez une couleur (ex: ENA blue).

Note: PlayScreen doit appeler DesignPrefs.load() puis utiliser _cfg.monoColor via colorFilter sur le PRIMARY mono.
