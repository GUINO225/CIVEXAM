# Patch — Intro du concours officiel + compte à rebours

Ce patch ajoute :
- `OfficialIntroScreen` : page de consignes (durée, barème, règles) avec **case d’acceptation** et **compte à rebours 3‑2‑1**.
- Mise à jour de `PlayScreen` : bouton **"Passer le concours officiel (simulation)"** qui ouvre l’intro.

## Installation
1) Copiez ces fichiers dans votre projet :
   - `lib/screens/official_intro_screen.dart`
   - `lib/screens/play_screen.dart` (remplacez l’existant)
2) Construisez l’app :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

> Prérequis : vous avez déjà `lib/screens/multi_exam_flow.dart` (fourni dans le patch précédent). Le bouton de l’intro lance ce flux multi‑épreuves.
