# CivExam App (Flutter) – Starter

## Lancer
```bash
flutter pub get
# Générer plateformes si nécessaire
flutter create .
flutter run
```

## Dossiers
- lib/app/theme.dart – thème (bleu #37478F)
- lib/services/question_loader.dart – charge JSON + filtre
- lib/services/mobile_money_service.dart – service de paiement Mobile Money
- lib/screens/* – Home, Matière, Chapitre, Quiz
- assets/questions/ena_sample.json – questions de test
- test/question_parsing_test.dart – test unitaire basique

Si tu cibles Android, copie/colle les fichiers de `../android_config_pack/` dans `android/` après `flutter create .`.

## Synchronisation cloud

La classe `CloudSync` tente d'initialiser Firebase et de connecter
l'utilisateur. Une connexion anonyme n'est effectuée que si la préférence
`allowAnonymousSignIn` n'est pas désactivée (stockée via
`SharedPreferences`).

Si cette préférence vaut `false`, l'application ne se connecte pas
automatiquement et l'écran de connexion est affiché.
