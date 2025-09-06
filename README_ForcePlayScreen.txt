CivExam — Force PlayScreen Patch
------------------------------------
Ce patch remet le point d'entrée de l'app sur le **nouveau PlayScreen**.

Fichier fourni : `lib/main.dart`

Étapes :
1) Remplacez votre fichier `lib/main.dart` par celui du patch.
2) (Recommandé) Désinstallez l’ancienne app de l’émulateur/appareil.
3) Exécutez :
   flutter clean
   flutter pub get
   flutter run

Notes :
- Ce patch n’altère AUCUN autre fichier.
- Si vous avez un Splash ou une redirection automatique,
  vérifiez que le Splash navigue bien vers `PlayScreen`.
