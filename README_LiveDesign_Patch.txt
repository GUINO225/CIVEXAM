CivExam — LIVE Design Patch
Fichiers inclus :
- lib/models/design_config.dart        (ajout tileIconSize, tileCenter)
- lib/services/design_bus.dart         (ValueNotifier pour le live)
- lib/screens/design_settings_screen.dart (pousse en LIVE via DesignBus + sliders icône/centrage)
- lib/screens/play_screen.dart         (écoute DesignBus + centre icône/texte + taille icône)

Étapes :
1) Copiez ces fichiers dans votre projet (remplacer les existants).
2) flutter clean && flutter pub get && flutter run
3) Ouvrez 🎨 Réglages design : les changements s’appliquent IMMÉDIATEMENT au PlayScreen.
