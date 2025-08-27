# Patch — Difficulté pour le mode Concours ENA (timing lié au niveau)

Ce patch **n’affecte que le mode "Concours ENA"** et ajoute des niveaux de difficulté qui ajustent le **timing** :

- **Facile** : ~90 s / question (temps total = 90×nbQ)
- **Normal (examen)** : **timings officiels** de chaque épreuve (inchangé)
- **Difficile** : ~45 s / question
- **Expert** : ~30 s / question

Le barème reste identique. L’état "Abandonné" est conservé dans l’historique.

## Fichier modifié
- `lib/screens/multi_exam_flow.dart` uniquement.

## Installation
1) Remplacez le fichier ci-dessus par celui du patch.
2) Rebuild :
```
flutter clean
flutter pub get
flutter run
```

## Personnalisation rapide
Dans `secondsPerQuestion(...)`, changez les valeurs 90/45/30 selon vos besoins.
