CivExam — Patch Intégration Classement (LOCAL)

Ce patch ajoute:
- 4 fichiers (modèle, store, écran, popup)
- 1 helper de hooks pour minimiser les changements
- 3 snippets prêts à coller dans vos fichiers existants

Étapes:
1) Copiez les dossiers `lib/models`, `lib/services`, `lib/screens`, `lib/widgets` dans votre projet (ne remplace PAS vos fichiers existants).
2) Ouvrez `patch_snippets/TRAINING_HOOK.txt` et `EXAM_HOOK.txt` et collez les lignes aux endroits indiqués.
3) (Optionnel) Ajoutez le bouton Classement dans le PlayScreen avec `patch_snippets/PLAYSCREEN_BUTTON.txt`.
4) Vérifiez que `shared_preferences` est présent dans `pubspec.yaml`.

Test:
- Terminez un entraînement -> la popup propose d'enregistrer -> allez dans le bouton 🏆 pour voir l'entrée.
- Terminez un concours -> même chose.
