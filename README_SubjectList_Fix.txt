Ce mini-patch supprime l'ancien paramètre `subjectIndex` du constructeur
`SubjectListScreen`.

Changement :
- retrait de `subjectIndex`, désormais inutile.

Migration :
- Remplacez les anciens appels `SubjectListScreen(subjectIndex: index)` par
  `const SubjectListScreen()`.

Le comportement visuel reste identique (liste des matières + navigation).
