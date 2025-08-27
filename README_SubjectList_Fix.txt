Ce mini-patch corrige l'erreur :
No named parameter with the name 'subjectIndex' pour SubjectListScreen.

Changement :
- Ajout d'un paramètre optionnel `subjectIndex` au constructeur
  (il est ignoré si non utilisé dans l'écran).

Application :
1) Remplacez `lib/screens/subject_list_screen.dart` par ce fichier.
2) Hot restart.

Compatibilité :
- Les anciens appels `SubjectListScreen(subjectIndex: index)` compilent à nouveau.
- Le comportement visuel reste identique (liste des matières + navigation).
