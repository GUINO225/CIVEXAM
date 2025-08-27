# Patch — main.dart (PlayScreen par défaut)

Ce patch remplace `lib/main.dart` afin de quitter le mode "Diagnostics des assets"
et démarrer directement sur l'écran principal **PlayScreen**.

## Installation
1. Copiez `lib/main.dart` dans votre projet (remplacez l'existant).
2. Puis exécutez :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
