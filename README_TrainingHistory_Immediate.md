# Patch — Historique d'entraînement immédiat (et persistant)

Ce patch modifie UNIQUEMENT l'historique d'entraînement pour qu'il soit visible **après chaque tentative**, sans limite de 5 minutes.

## Fichiers modifiés
- `lib/services/training_history_store.dart` : suppression du TTL 5 min, conservation des **100** dernières tentatives, migration automatique depuis l'ancien format.
- `lib/screens/training_history_screen.dart` : libellés mis à jour, bouton *Actualiser*, suppression de la mention "≤ 5 min".

## Intégration
1) Remplacez ces deux fichiers dans votre projet.
2) Rebuild :
```
flutter clean
flutter pub get
flutter run
```
