# CivExam App (Flutter) – Starter

## Lancer
```bash
dart run tool/ensure_lfs_assets.dart
flutter pub get
# Générer plateformes si nécessaire
flutter create .
flutter run
```

La commande `ensure_lfs_assets` configure Git LFS et télécharge les PNG
hébergés côté serveur. Elle vérifie aussi que les binaires clés (logo de
splash, etc.) ne sont pas de simples « pointeurs » de quelques octets.
Ainsi, plus besoin de re-commiter les assets ou de diagnostiquer un échec
`flutter run` : les bonnes images sont toujours présentes après un clone.

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

### Index Firestore requis pour le classement

Le service `CompetitionService.topEntries()` interroge la collection
`competition_scores` avec un filtre sur `mode` et un tri composé sur
`percent` (descendant) puis `durationSec` (ascendant). Firestore réclame
un index composite pour ce type de requête :

1. Dans la console Firebase, ouvrez **Firestore Database › Indexes**.
2. Ajoutez un index composite sur la collection `competition_scores` avec
   les champs suivants :
   - `mode` : **Ascending** (utilisé en filtre d'égalité),
   - `percent` : **Descending**,
   - `durationSec` : **Ascending**.
3. Attendez que l'index soit construit, puis relancez l'application ; le
   classement renvoyé par `topEntries()` sera correctement trié sans
   repasser par le mode dégradé.

> ℹ️ L'index doit être créé dans chaque projet Firebase utilisé par
> l'application (dev, staging, prod, …).


### Déployer l'index avec Firebase CLI (recommandé)

Pour éviter l'erreur `cloud_firestore/failed-precondition` ("The query requires an index"),
le dépôt inclut maintenant `firestore.indexes.json`. Vous pouvez publier l'index avec :

```bash
firebase deploy --only firestore:indexes
```

Assurez-vous d'être connecté au bon projet Firebase (`firebase use <project-id>`).

