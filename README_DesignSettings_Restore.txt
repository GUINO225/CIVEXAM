CivExam — Restaure le système de réglages design
Ce patch remplace UNIQUEMENT `lib/screens/play_screen.dart` et :
- applique DesignPrefs (palette, wave, blur/opacités)
- ajoute un bouton 🎨 pour ouvrir DesignSettingsScreen puis recharge les prefs au retour
- conserve le bouton 🏆 Classement et la navigation

Étapes :
1) Remplace `lib/screens/play_screen.dart` par ce fichier.
2) Hot restart (ou flutter clean/pub get/run).
3) Ouvre le menu 🎨 et change palette/blur/opacité/wave : le PlayScreen s’actualise au retour.
