# CivExam – Étape 2 (Patch)
Ce patch ajoute :
- **Mode Examen** avec **timer** et **résultats détaillés**
- **Historique des scores** (stockage local `shared_preferences`)
- **UI** : accueil avec **dégradé** + **carte glassmorphisme**, bouton Historique
- Sélecteur **temps par question** (1–3 min)

## Installation
1) **Sauvegardez** votre projet actuel.
2) **Copiez** les fichiers de ce patch dans votre projet, en respectant les mêmes chemins (`lib/...`, `pubspec.yaml`).
3) Exécutez :
```bash
flutter pub get
flutter run
```
*(Android)*

## Fichiers clés
- `lib/screens/exam_screen.dart` – examen chronométré
- `lib/screens/result_screen.dart` – récap détaillé
- `lib/services/history_store.dart` – stockage de l’historique des examens
- `lib/services/training_history_store.dart` – stockage de l’historique d’entraînement
- `lib/screens/exam_history_screen.dart` – historique des examens
- `lib/screens/training_history_screen.dart` – historique d’entraînement
- `lib/widgets/glass_card.dart` – composant glassmorphism
- `lib/screens/chapter_list_screen.dart` – boutons Entraînement/Examen + temps/question
- `pubspec.yaml` – ajoute `shared_preferences`
