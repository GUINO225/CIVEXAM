# Étape 4 — Splash animé + Bouton "Jouer"

Ce patch ajoute :
- Un **splash animé in‑app** (1.8s) avec le logo et un bouton **"Jouer"**.
- Un patch pour démarrer l’app directement sur ce splash.

## Fichiers inclus
- `lib/screens/splash_animated.dart` — nouvel écran.
- `lib/main.dart.patch.txt` — contenu prêt si vous voulez démarrer sur le splash animé.
- `lib/screens/home_screen.dart.patch.txt` — astuce pour ajouter un bouton "Jouer" aussi sur l’accueil (optionnel).

## Installation
1. Copiez `lib/screens/splash_animated.dart` dans votre projet.
2. Ouvrez `lib/main.dart` et remplacez-le par le contenu de `lib/main.dart.patch.txt` **ou** adaptez votre `home:` pour utiliser `SplashAnimated()`.
3. Assurez-vous d’avoir `assets/images/logo.png` côté projet.

## Commandes
```bash
flutter pub get
flutter run
```

## Personnalisation
- Durée auto-continue : modifiez `Duration(milliseconds: 1800)` dans `initState()`.
- Pour forcer uniquement le bouton "Jouer" (sans auto), supprimez le `Timer` et ne gardez que `_goNext()` sur onPressed.
