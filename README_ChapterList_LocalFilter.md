# Patch — ChapterListScreen avec filtrage local (sans `QuestionLoader.filterBy`)

Ce patch remplace `lib/screens/chapter_list_screen.dart` pour filtrer les questions **localement**,
sans dépendre de `QuestionLoader.filterBy`. Utile si votre `QuestionLoader` ne définit pas cette méthode.

## Installation
1. Copiez `lib/screens/chapter_list_screen.dart` dans votre projet (remplacez l’existant).
2. Rebuild propre :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
