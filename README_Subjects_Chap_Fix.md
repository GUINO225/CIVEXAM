# Patch — Alignement des matières/chapitres + filtre tolérant

## Pourquoi ce patch ?
Vous voyiez les **mêmes catégories** et, dans les quiz, **aucune question** : vos intitulés
de matières/chapitres dans l’app ne correspondaient pas à ceux des fichiers JSON.
Le filtrage strict renvoyait alors 0 résultat.

## Ce que fait le patch
1. **Aligne la taxonomie** (`lib/data/ena_taxonomy.dart`) avec les 6 matières et chapitres présents dans la banque JSON.
2. **Rend le filtrage tolérant** (`lib/services/question_loader.dart`) : alias + fallback par matière.
3. **Améliore l’écran de chapitre** (`lib/screens/chapter_list_screen.dart`) pour utiliser ce filtre et afficher un message clair si 0 question.

## Installation
1) Copiez ces 3 fichiers dans votre projet (écrasez les existants) :
   - `lib/data/ena_taxonomy.dart`
   - `lib/services/question_loader.dart`
   - `lib/screens/chapter_list_screen.dart`
2) Rebuild :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Résultat attendu
- Les catégories affichent désormais : *Culture Générale*, *Droit Constitutionnel*, *Problèmes Économiques & Sociaux*, *Aptitude Numérique*, *Aptitude Verbale*, *Organisation & Logique*.
- En sélectionnant un chapitre, vous voyez bien **les questions** correspondantes.
