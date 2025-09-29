# CivExam

![Aperçu PlayScreen](Screens%20Image/3.%20Home.png)

## Aperçu
CivExam est une application Flutter destinée à l’entraînement aux concours et examens de culture générale. Elle propose un écran PlayScreen personnalisable, des quiz chronométrés et un classement connecté à Firebase pour stimuler la progression.

## Fonctionnalités clés
- **PlayScreen modulable** : navigation par onglets (Accueil, Dashboard, Quiz, Historique, Profil, Paramètres) avec un FAB pour lancer un nouvel entraînement, carrousel d’actualités et aperçu des meilleurs scores directement sur l’écran d’accueil.
- **Relance rapide des quiz** : génération d’un tirage mélangé à partir de la banque ENA, sauvegarde de l’état d’un quiz en cours, historique et enregistrement automatique des performances une fois la session terminée.
- **Classement en direct** : écran dédié permettant de filtrer les scores, mettre à jour le podium et afficher le détail (pourcentage, questions correctes, durée) pour chaque participant. Les données proviennent du service Firestore `CompetitionService` qui gère l’enregistrement et la récupération triée des entrées.

## Installation et lancement
1. Installez les dépendances Flutter puis (si nécessaire) regénérez les plateformes natives :
   ```bash
   flutter pub get
   flutter create .
   flutter run
   ```
2. Copiez les éventuels fichiers de configuration Android (keystore, etc.) dans `android/` si votre environnement en nécessite.
3. Les configurations de thèmes et préférences sont chargées automatiquement via `DesignPrefs` au démarrage de l’application.

## Configuration Firebase
- L’application initialise Firebase avec les paramètres générés dans `firebase_options.dart` et active la persistance Firestore lors du démarrage.
- Le classement `competition_scores` requiert un index composite `mode` (Ascending) / `percent` (Descending) / `durationSec` (Ascending) pour exécuter la requête triée sans mode dégradé. Ce même service assure également la purge d’anciens modes et le flux en direct des meilleurs scores.
- Pensez à fournir les fichiers `google-services.json` et `GoogleService-Info.plist` appropriés dans `android/` et `ios/` afin d’utiliser l’authentification et Firestore.

## Ressources complémentaires
- Guide de migration Arcade : [docs/arcade_level_migration.md](docs/arcade_level_migration.md).
- Captures supplémentaires disponibles dans le dossier [`Screens Image/`](Screens%20Image/).
- Les anciens README techniques ont été archivés dans `docs/archive/legacy-readmes/` pour référence.

## Support & FAQ
- **FAQ in-app** : consultez la section dédiée depuis l’écran Paramètres (captures `8.1 FAQ.png` dans `Screens Image/`).
- **Support projet** : ouvrez une issue GitHub avec un journal d’exécution (`flutter run -v`) et, si nécessaire, les logs Firebase.
- **Questions fréquentes** :
  - *Comment relancer un quiz interrompu ?* — Utilisez la bannière « Reprendre » sur le PlayScreen ; l’état est stocké via `OngoingQuickQuizStore` et les questions sont rechargées à la reprise.
  - *Comment mettre à jour le classement ?* — Depuis l’écran Classement, appuyez sur l’icône de rafraîchissement ; le service re-synchronise les entrées Firestore triées.
