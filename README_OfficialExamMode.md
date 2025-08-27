# Patch — Mode Examen ENA (barème négatif) + Parcours multi-épreuves

## Fichiers ajoutés
- `lib/services/scoring.dart` — Barème et coefficient
- `lib/screens/exam_full_screen.dart` — Examen officiel : toutes les questions à la fois + chrono + pénalité
- `lib/screens/multi_exam_flow.dart` — Enchaînement de 4 épreuves (60 min chacune, coef 2)

## Fichier modifié
- `lib/screens/chapter_list_screen.dart` — ajoute 2 boutons :
  - **Examen OFFICIEL (barème négatif)**
  - **Parcours multi-épreuves (x4)**

## Barème par défaut
- Correct : **+1**
- Mauvaise réponse : **–1**
- Blanc : **0**
- Coefficient : **×2**

Vous pouvez changer ces valeurs dans les boutons (paramètre `ExamScoring`).

## Installation
1) Copiez les 4 fichiers dans votre projet (écrasez `chapter_list_screen.dart`).
2) Build :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Notes
- `ExamFullScreen` fonctionne avec une liste de questions déjà filtrée (on lui passe `_all`). 
- `MultiExamFlowScreen` charge toute la banque et filtre par matière/chapitre en interne, avec alias/fallback.
- Le **barème est paramétrable** pour s’aligner sur une session de concours donnée.
