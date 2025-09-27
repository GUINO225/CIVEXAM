import 'package:flutter/material.dart';

enum HomeCategory {
  quickPrep,
  courses,
  bank,
  resources,
  history,
  challenge,
  help,
}

class CategoryMenuItem {
  final String title;
  final IconData icon;
  final Color accentColor;

  const CategoryMenuItem({
    required this.title,
    required this.icon,
    required this.accentColor,
  });
}

class CategoryDefinition {
  final HomeCategory category;
  final String keyName;
  final String title;
  final String description;
  final List<int> itemIndexes;
  final IconData icon;
  final Color accentColor;

  const CategoryDefinition({
    required this.category,
    required this.keyName,
    required this.title,
    required this.description,
    required this.itemIndexes,
    required this.icon,
    required this.accentColor,
  });
}

const Color _violetAccent = Color(0xFF7C4DFF);
const Color _deepVioletAccent = Color(0xFF5B2E91);
const Color _blueAccent = Color(0xFF1A73E8);
const Color _tealAccent = Color(0xFF00897B);
const Color _emeraldAccent = Color(0xFF2E7D32);
const Color _amberAccent = Color(0xFFFFB300);
const Color _orangeAccent = Color(0xFFFF7043);
const Color _pinkAccent = Color(0xFFEC407A);
const Color _aquaAccent = Color(0xFF00ACC1);

const List<CategoryMenuItem> kCategoryMenuItems = <CategoryMenuItem>[
  CategoryMenuItem(
    title: 'Simulation concours ENA',
    icon: Icons.auto_awesome_rounded,
    accentColor: _violetAccent,
  ),
  CategoryMenuItem(
    title: 'Entraînement par matière',
    icon: Icons.menu_book_rounded,
    accentColor: _blueAccent,
  ),
  CategoryMenuItem(
    title: 'Historique examens',
    icon: Icons.history_edu_rounded,
    accentColor: _emeraldAccent,
  ),
  CategoryMenuItem(
    title: 'Historique entraînement',
    icon: Icons.timeline_rounded,
    accentColor: _amberAccent,
  ),
  CategoryMenuItem(
    title: 'Comment ça marche ?',
    icon: Icons.live_help_rounded,
    accentColor: _pinkAccent,
  ),
  CategoryMenuItem(
    title: 'Classement',
    icon: Icons.emoji_events_rounded,
    accentColor: _amberAccent,
  ),
  CategoryMenuItem(
    title: 'Compétition',
    icon: Icons.whatshot_rounded,
    accentColor: _orangeAccent,
  ),
  CategoryMenuItem(
    title: 'Culture générale (CI & Afrique)',
    icon: Icons.public_rounded,
    accentColor: _blueAccent,
  ),
  CategoryMenuItem(
    title: 'Droit public (Consti/Administratif)',
    icon: Icons.gavel_rounded,
    accentColor: _deepVioletAccent,
  ),
  CategoryMenuItem(
    title: 'Finances publiques (CI)',
    icon: Icons.account_balance_rounded,
    accentColor: _emeraldAccent,
  ),
  CategoryMenuItem(
    title: 'Économie & gestion',
    icon: Icons.show_chart_rounded,
    accentColor: _orangeAccent,
  ),
  CategoryMenuItem(
    title: 'Relations internationales & UE',
    icon: Icons.language_rounded,
    accentColor: _aquaAccent,
  ),
  CategoryMenuItem(
    title: 'Institutions de la Côte d’Ivoire',
    icon: Icons.flag_rounded,
    accentColor: _emeraldAccent,
  ),
  CategoryMenuItem(
    title: 'Note de synthèse',
    icon: Icons.description_rounded,
    accentColor: _pinkAccent,
  ),
  CategoryMenuItem(
    title: 'Méthodo QRC / QCM',
    icon: Icons.fact_check_rounded,
    accentColor: _emeraldAccent,
  ),
  CategoryMenuItem(
    title: 'Examens blancs ENA',
    icon: Icons.timer_rounded,
    accentColor: _deepVioletAccent,
  ),
  CategoryMenuItem(
    title: 'Communication administrative',
    icon: Icons.record_voice_over_rounded,
    accentColor: _pinkAccent,
  ),
  CategoryMenuItem(
    title: 'TIC & Bureautique',
    icon: Icons.computer_rounded,
    accentColor: _blueAccent,
  ),
  CategoryMenuItem(
    title: 'Comptabilité publique',
    icon: Icons.request_quote_rounded,
    accentColor: _amberAccent,
  ),
  CategoryMenuItem(
    title: 'Anglais (option)',
    icon: Icons.translate_rounded,
    accentColor: _aquaAccent,
  ),
  CategoryMenuItem(
    title: 'Banque de sujets ENA CI',
    icon: Icons.folder_special_rounded,
    accentColor: _deepVioletAccent,
  ),
  CategoryMenuItem(
    title: 'Corrigés détaillés',
    icon: Icons.task_rounded,
    accentColor: _emeraldAccent,
  ),
  CategoryMenuItem(
    title: 'Sujets par filière (A/B/C)',
    icon: Icons.view_module_rounded,
    accentColor: _tealAccent,
  ),
  CategoryMenuItem(
    title: 'Constitution & textes clés',
    icon: Icons.menu_book_outlined,
    accentColor: _blueAccent,
  ),
  CategoryMenuItem(
    title: 'Programme officiel (PDF)',
    icon: Icons.picture_as_pdf_rounded,
    accentColor: _pinkAccent,
  ),
  CategoryMenuItem(
    title: 'Calendrier des concours',
    icon: Icons.calendar_month_rounded,
    accentColor: _orangeAccent,
  ),
  CategoryMenuItem(
    title: 'Textes ENA / Arrêtés / Guides',
    icon: Icons.library_books_rounded,
    accentColor: _emeraldAccent,
  ),
];

const List<CategoryDefinition> kHomeCategories = <CategoryDefinition>[
  CategoryDefinition(
    category: HomeCategory.quickPrep,
    keyName: 'quick',
    title: 'Prépa rapide',
    description: 'Simulations, examens blancs et révisions ciblées.',
    itemIndexes: [0, 15, 1],
    icon: Icons.auto_awesome_rounded,
    accentColor: _violetAccent,
  ),
  CategoryDefinition(
    category: HomeCategory.courses,
    keyName: 'courses',
    title: 'Cours ENA (Côte d’Ivoire)',
    description: 'Toutes les matières et méthodologies pour réussir l’ENA.',
    itemIndexes: [7, 16, 8, 17, 9, 10, 18, 11, 12, 13, 14, 19],
    icon: Icons.school_rounded,
    accentColor: _blueAccent,
  ),
  CategoryDefinition(
    category: HomeCategory.bank,
    keyName: 'bank',
    title: 'Sujets & corrigés',
    description: 'Accédez aux banques d’annales et corrigés thématiques.',
    itemIndexes: [20, 21, 22],
    icon: Icons.folder_special_rounded,
    accentColor: _deepVioletAccent,
  ),
  CategoryDefinition(
    category: HomeCategory.resources,
    keyName: 'resources',
    title: 'Ressources officielles (CI)',
    description: 'Textes, calendriers et documents de référence.',
    itemIndexes: [23, 24, 25, 26],
    icon: Icons.menu_book_outlined,
    accentColor: _emeraldAccent,
  ),
  CategoryDefinition(
    category: HomeCategory.history,
    keyName: 'history',
    title: 'Historique & suivi',
    description: 'Retrouvez vos examens et entraînements précédents.',
    itemIndexes: [2, 3],
    icon: Icons.history_rounded,
    accentColor: _amberAccent,
  ),
  CategoryDefinition(
    category: HomeCategory.challenge,
    keyName: 'challenge',
    title: 'Défis & classement',
    description: 'Classements et compétitions chronométrées.',
    itemIndexes: [5, 6],
    icon: Icons.emoji_events_rounded,
    accentColor: _amberAccent,
  ),
  CategoryDefinition(
    category: HomeCategory.help,
    keyName: 'help',
    title: 'Aide & thèmes',
    description: 'Guides d’utilisation et futures thématiques.',
    itemIndexes: [4],
    icon: Icons.help_outline_rounded,
    accentColor: _pinkAccent,
  ),
];
