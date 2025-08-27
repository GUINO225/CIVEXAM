# Étape 5 — Synchronisation Cloud (Firebase)

Fichiers:
- lib/services/cloud_sync.dart
- lib/services/history_service.dart.patch.txt
- pubspec_cloud_sync.yaml

Intégration:
1) Copiez cloud_sync.dart dans lib/services/.
2) Modifiez lib/services/history_service.dart (import + appel uploadAttempt).
3) Ajoutez dans pubspec.yaml les dépendances de pubspec_cloud_sync.yaml.
4) Android:
   - Ajoutez votre google-services.json dans android/app/.
   - android/settings.gradle: plugins { id("com.google.gms.google-services") version "4.4.2" apply false }
   - android/app/build.gradle.kts: plugins { id("com.google.gms.google-services") }
5) Commandes:
   flutter clean
   flutter pub get
   flutter run
