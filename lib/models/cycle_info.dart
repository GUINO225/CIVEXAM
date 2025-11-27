import 'package:flutter/material.dart';

/// Information de base pour chaque cycle ENA.
class CycleInfo {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final Color accent;
  final List<String> subjects;
  final IconData icon;

  const CycleInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.accent,
    required this.subjects,
    required this.icon,
  });
}

/// Les trois cycles du concours ENA.
const List<CycleInfo> enaCycles = <CycleInfo>[
  CycleInfo(
    id: 'cs',
    title: 'Cycle Supérieur',
    subtitle:
        'Bac + 4 minimum • Missions stratégiques et décisions publiques',
    color: Color(0xFF3748B4),
    accent: Color(0xFF4E64E8),
    subjects: [
      'Culture générale',
      'Droit public',
      'Administration publique',
      'Analyse documentaire / Résumé',
      'Étude de cas / Note administrative',
      'Anglais',
      'Économie',
    ],
    icon: Icons.workspace_premium_rounded,
  ),
  CycleInfo(
    id: 'cms',
    title: 'Cycle Moyen Supérieur',
    subtitle: 'Bac + 2 • Coordination et suivi opérationnel',
    color: Color(0xFFF29F05),
    accent: Color(0xFFFFB74D),
    subjects: [
      'Culture générale',
      'Droit (constitutionnel + administratif)',
      'Économie',
      'Note de synthèse',
      'Anglais',
      'Mathématiques financières / Analyse',
      'Informatique de base (selon sessions)',
    ],
    icon: Icons.account_tree_rounded,
  ),
  CycleInfo(
    id: 'cm',
    title: 'Cycle Moyen',
    subtitle: 'Baccalauréat • Accès le plus large mais concours très sélectif',
    color: Color(0xFF20A86A),
    accent: Color(0xFF2EC88A),
    subjects: [
      'Culture générale',
      'Français (compréhension, expression, orthographe)',
      'Mathématiques / Logique',
      'Connaissance du civisme et des institutions',
      'Informatique de base (parfois)',
    ],
    icon: Icons.handyman_rounded,
  ),
];

CycleInfo? cycleById(String? id) {
  if (id == null) return null;
  try {
    return enaCycles.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}
