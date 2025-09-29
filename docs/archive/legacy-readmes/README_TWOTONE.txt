CivExam — Two‑Tone Fallback Patch
Problème: les détails BLANCS ne s'affichent pas quand le set coloré n'est pas chargé (fallback mono teinté).
Solution: si un set coloré est sélectionné mais introuvable, on rend un SVG *de secours* deux tons (couleur du set + BLANC).

Fichier à remplacer: lib/screens/play_screen.dart

Étapes:
1) Copier/remplacer le fichier.
2) flutter clean && flutter pub get && flutter run
3) Réglages design:
   - Icônes monochromes: OFF (pour tester le set coloré)
   - Set: teal/amber/…
   - Si l'asset set est présent → rendu natif multi‑couleurs (blancs inclus).
   - Si l'asset set manque → rendu DEUX TONS (set + blanc), donc détails visibles.
