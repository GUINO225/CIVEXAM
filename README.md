# CivExam App (Flutter) – Starter

## Lancer
```bash
flutter pub get
# Générer plateformes si nécessaire
flutter create .
flutter run
```

## Signature Android
Pour les builds de production, les mots de passe du keystore ne sont plus inclus dans le dépôt.
Déclarez `storePassword` et `keyPassword` dans `~/.gradle/gradle.properties` :

```properties
storePassword=mon-mot-de-passe-store
keyPassword=mon-mot-de-passe-cle
```

ou exportez-les comme variables d’environnement avant la compilation :

```bash
export STORE_PASSWORD="mon-mot-de-passe-store"
export KEY_PASSWORD="mon-mot-de-passe-cle"
```

## Dossiers
- lib/app/theme.dart – thème (bleu #37478F)
- lib/services/question_loader.dart – charge JSON + filtre
- lib/services/mobile_money_service.dart – service de paiement Mobile Money
- lib/screens/* – Home, Matière, Chapitre, Quiz
- assets/questions/ena_sample.json – questions de test
- test/question_parsing_test.dart – test unitaire basique

Si tu cibles Android, copie/colle les fichiers de `../android_config_pack/` dans `android/` après `flutter create .`.
