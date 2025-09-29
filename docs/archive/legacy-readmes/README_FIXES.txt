
Corrections d'erreurs de compilation :

1) multi_exam_flow.dart
   - _durationSec : secondsPerQuestion(_difficulty) peut être null et renvoie un num.
   - Correction: on récupère un entier sûr puis on multiplie.
     ```dart
     final int _perQ = (secondsPerQuestion(_difficulty) ?? 0);
     final int _durationSec = _perQ * _globalTotal;
     ```

2) leaderboard_screen.dart
   - _load() : ne pas utiliser await dans la closure de setState ; on attend d'abord puis setState().
   - _fmtDuration() : formattage Dart, pas de '%d'/'%s' façon Python.
