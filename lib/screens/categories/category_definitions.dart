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
  final String palette;
  final IconData? icon;
  final String? asset;

  const CategoryMenuItem.icon(this.title, this.icon, this.palette) : asset = null;
  const CategoryMenuItem.asset(this.title, this.asset, this.palette) : icon = null;
}

class CategoryDefinition {
  final HomeCategory category;
  final String keyName;
  final String title;
  final String description;
  final List<int> itemIndexes;
  final IconData? icon;
  final String? asset;

  const CategoryDefinition({
    required this.category,
    required this.keyName,
    required this.title,
    required this.description,
    required this.itemIndexes,
    this.icon,
    this.asset,
  });
}

const List<CategoryMenuItem> kCategoryMenuItems = <CategoryMenuItem>[
  CategoryMenuItem.asset(
    'Simulation concours ENA',
    'assets/images/tuiles/Simulation concours ENA.png',
    'violetRose',
  ),
  CategoryMenuItem.asset(
    'Entraînement par matière',
    'assets/images/tuiles/Entraînement par matière.png',
    'sereneBlue',
  ),
  CategoryMenuItem.asset(
    'Historique examens',
    'assets/images/tuiles/Historique examens.png',
    'lightGreen',
  ),
  CategoryMenuItem.asset(
    'Historique entraînement',
    'assets/images/tuiles/Historique entraînement.png',
    'softYellow',
  ),
  CategoryMenuItem.asset(
    'Comment ça marche ?',
    'assets/images/tuiles/Comment ça marche.png',
    'powderPink',
  ),
  CategoryMenuItem.asset(
    'Classement',
    'assets/images/tuiles/Classement.png',
    'royalViolet',
  ),
  CategoryMenuItem.asset(
    'Compétition',
    'assets/images/tuiles/Compétition.png',
    'forestGreen',
  ),
  CategoryMenuItem.asset(
    'Culture générale (CI & Afrique)',
    'assets/images/tuiles/Culture générale (CI & Afrique).png',
    'sereneBlue',
  ),
  CategoryMenuItem.asset(
    'Droit public (Consti/Administratif)',
    'assets/images/tuiles/Droit public Consti Administratif.png',
    'royalViolet',
  ),
  CategoryMenuItem.asset(
    'Finances publiques (CI)',
    'assets/images/tuiles/Finances publiques (CI).png',
    'lightGreen',
  ),
  CategoryMenuItem.asset(
    'Économie & gestion',
    'assets/images/tuiles/Économie & gestion.png',
    'softYellow',
  ),
  CategoryMenuItem.asset(
    'Relations internationales & UE',
    'assets/images/tuiles/Relations internationales & UE.png',
    'violetRose',
  ),
  CategoryMenuItem.asset(
    'Institutions de la Côte d’Ivoire',
    "assets/images/tuiles/Institutions de la Côte d'ivoire.png",
    'sereneBlue',
  ),
  CategoryMenuItem.icon('Note de synthèse', Icons.description_rounded, 'powderPink'),
  CategoryMenuItem.icon('Méthodo QRC / QCM', Icons.checklist_rtl_rounded, 'forestGreen'),
  CategoryMenuItem.icon('Examens blancs ENA', Icons.timer_rounded, 'royalViolet'),
  CategoryMenuItem.icon(
    'Communication administrative',
    Icons.record_voice_over_rounded,
    'powderPink',
  ),
  CategoryMenuItem.icon('TIC & Bureautique', Icons.computer_rounded, 'sereneBlue'),
  CategoryMenuItem.icon('Comptabilité publique', Icons.request_quote_rounded, 'lightGreen'),
  CategoryMenuItem.icon('Anglais (option)', Icons.translate_rounded, 'softYellow'),
  CategoryMenuItem.icon('Banque de sujets ENA CI', Icons.folder_special_rounded, 'royalViolet'),
  CategoryMenuItem.icon('Corrigés détaillés', Icons.task_rounded, 'violetRose'),
  CategoryMenuItem.icon('Sujets par filière (A/B/C)', Icons.view_module_rounded, 'forestGreen'),
  CategoryMenuItem.icon('Constitution & textes clés', Icons.menu_book_outlined, 'sereneBlue'),
  CategoryMenuItem.icon('Programme officiel (PDF)', Icons.picture_as_pdf_rounded, 'powderPink'),
  CategoryMenuItem.icon('Calendrier des concours', Icons.calendar_month_rounded, 'softYellow'),
  CategoryMenuItem.icon(
    'Textes ENA / Arrêtés / Guides',
    Icons.library_books_rounded,
    'lightGreen',
  ),
];

const List<CategoryDefinition> kHomeCategories = <CategoryDefinition>[
  CategoryDefinition(
    category: HomeCategory.quickPrep,
    keyName: 'quick',
    title: 'Prépa rapide',
    description: 'Simulations, examens blancs et révisions ciblées.',
    itemIndexes: [0, 15, 1],
    asset: 'assets/images/tuiles/Simulation concours ENA.png',
  ),
  CategoryDefinition(
    category: HomeCategory.courses,
    keyName: 'courses',
    title: 'Cours ENA (Côte d’Ivoire)',
    description: 'Toutes les matières et méthodologies pour réussir l’ENA.',
    itemIndexes: [7, 16, 8, 17, 9, 10, 18, 11, 12, 13, 14, 19],
    asset: 'assets/images/tuiles/Culture générale (CI & Afrique).png',
  ),
  CategoryDefinition(
    category: HomeCategory.bank,
    keyName: 'bank',
    title: 'Sujets & corrigés',
    description: 'Accédez aux banques d’annales et corrigés thématiques.',
    itemIndexes: [20, 21, 22],
    icon: Icons.folder_special_rounded,
  ),
  CategoryDefinition(
    category: HomeCategory.resources,
    keyName: 'resources',
    title: 'Ressources officielles (CI)',
    description: 'Textes, calendriers et documents de référence.',
    itemIndexes: [23, 24, 25, 26],
    icon: Icons.menu_book_outlined,
  ),
  CategoryDefinition(
    category: HomeCategory.history,
    keyName: 'history',
    title: 'Historique & suivi',
    description: 'Retrouvez vos examens et entraînements précédents.',
    itemIndexes: [2, 3],
    asset: 'assets/images/tuiles/Historique examens.png',
  ),
  CategoryDefinition(
    category: HomeCategory.challenge,
    keyName: 'challenge',
    title: 'Défis & classement',
    description: 'Classements et compétitions chronométrées.',
    itemIndexes: [5, 6],
    asset: 'assets/images/tuiles/Classement.png',
  ),
  CategoryDefinition(
    category: HomeCategory.help,
    keyName: 'help',
    title: 'Aide & thèmes',
    description: 'Guides d’utilisation et futures thématiques.',
    itemIndexes: [4],
    icon: Icons.help_outline_rounded,
  ),
];
