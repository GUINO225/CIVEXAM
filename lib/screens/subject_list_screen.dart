import 'package:flutter/material.dart';

import '../data/ena_taxonomy.dart';
import '../services/question_loader.dart';
import '../widgets/play_bottom_nav_bar.dart';
import 'chapter_list_screen.dart';
import 'play_screen.dart';

/// Palette cohérente (violet + surface claire)
class _Brand {
  static const primary = Color(0xFF6C5CE7);
  static const primaryDark = Color(0xFF5B4DE1);
  static const secondary = Color(0xFF7F6AF8);
  static const surface = Color(0xFFF7F5FF);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF1E1E28);
  static const textMuted = Color(0xFF6E6B7A);
  static const border = Color(0xFFE6E1F9);
  static const chipBg = Color(0xFFEFEAFF);
}

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key, this.allowedSubjects, this.cycleName});

  final List<String>? allowedSubjects;
  final String? cycleName;

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  bool _loading = true;
  String? _error;
  List<Subject> _subjects = const <Subject>[];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await QuestionLoader.loadENA();
      if (!mounted) return;
      final allowed = widget.allowedSubjects;
      final allowedSet =
          allowed == null ? null : allowed.map((e) => e.toLowerCase()).toSet();
      final loaded = allowedSet == null || allowedSet.isEmpty
          ? subjectsENA
          : subjectsENA
              .where((s) => allowedSet.contains(s.name.toLowerCase()))
              .toList();
      setState(() {
        _subjects = loaded;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openChapter(String subjectName, String chapterName) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterListScreen(
          subjectName: subjectName,
          chapterName: chapterName,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: _Brand.secondary),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Une erreur est survenue.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadSubjects,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError();

    final hasCycleFilter = widget.cycleName != null && widget.cycleName!.trim().isNotEmpty;

    if (_subjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_outlined, size: 48, color: _Brand.secondary),
              const SizedBox(height: 12),
              Text(
                hasCycleFilter
                    ? 'Aucune matière disponible pour ce cycle pour le moment.'
                    : 'Aucune matière disponible pour le moment.',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadSubjects,
                child: const Text('Actualiser'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubjects,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _subjects.length + (hasCycleFilter ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (hasCycleFilter && index == 0) {
            return _CycleHeader(cycleName: widget.cycleName!);
          }

          final subject = _subjects[index - (hasCycleFilter ? 1 : 0)];
          return _SubjectTile(
            subject: subject,
            onOpenChapter: (chapterName) =>
                _openChapter(subject.name, chapterName),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final themed = base.copyWith(
      scaffoldBackgroundColor: _Brand.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _Brand.primary,
        brightness: base.brightness,
      ).copyWith(
        primary: _Brand.primary,
        surface: _Brand.surface,
        background: _Brand.surface,
        onSurface: _Brand.text,
        onPrimary: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _Brand.text,
        displayColor: _Brand.text,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: _Brand.surface,
        foregroundColor: _Brand.text,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: _Brand.border,
      expansionTileTheme: const ExpansionTileThemeData(
        tilePadding: EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: EdgeInsets.only(left: 8, right: 8, bottom: 12),
        collapsedIconColor: _Brand.textMuted,
        iconColor: _Brand.primaryDark,
      ),
    );

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(title: const Text('Choisir une matière')),
        body: _buildBody(),
        bottomNavigationBar: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final Color brand = theme.colorScheme.primary;
            final Color onBrand = theme.colorScheme.onPrimary;
            final Color navHighlight =
                Color.alphaBlend(onBrand.withOpacity(0.14), brand);
            return PlayBottomNavBar(
              destinations: playNavDestinations,
              selectedIndex: 2,
              backgroundColor: brand,
              highlightColor: navHighlight,
              foregroundColor: onBrand,
              onDestinationSelected: (index) {
                if (index == 2) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayScreen(initialIndex: index),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// ---------- Helpers: choix d’icône/couleur par matière ----------

String _normalize(String s) {
  final lower = s.toLowerCase();
  return lower
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('û', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ç', 'c');
}

IconData _iconForSubject(String name) {
  final n = _normalize(name);
  if (n.contains('droit')) return Icons.gavel_rounded;
  if (n.contains('culture') || n.contains('generale')) return Icons.public_rounded;
  if (n.contains('communication')) return Icons.forum_rounded;
  if (n.contains('administrat')) return Icons.admin_panel_settings_rounded;
  if (n.contains('economie') || n.contains('economi')) return Icons.trending_up_rounded;
  if (n.contains('finance')) return Icons.account_balance_rounded;
  if (n.contains('statist')) return Icons.stacked_line_chart_rounded;
  if (n.contains('math')) return Icons.calculate_rounded;
  if (n.contains('informatique') || n.contains('tic')) return Icons.computer_rounded;
  if (n.contains('science')) return Icons.biotech_rounded;
  if (n.contains('geograph')) return Icons.map_rounded;
  if (n.contains('histoire')) return Icons.history_edu_rounded;
  if (n.contains('anglais') || n.contains('francais') || n.contains('français')) {
    return Icons.translate_rounded;
  }
  if (n.contains('logique') || n.contains('raisonnement') || n.contains('aptitude')) {
    return Icons.psychology_rounded;
  }
  return Icons.menu_book_rounded;
}

Color _colorForSubject(String name) {
  final n = _normalize(name);
  if (n.contains('droit')) return const Color(0xFF3949AB); // indigo
  if (n.contains('culture') || n.contains('generale')) return const Color(0xFF6A1B9A); // purple
  if (n.contains('communication')) return const Color(0xFF00897B); // teal
  if (n.contains('administrat')) return const Color(0xFF5C6BC0); // indigo lighten
  if (n.contains('economie') || n.contains('economi')) return const Color(0xFFF57C00); // orange
  if (n.contains('finance')) return const Color(0xFF2E7D32); // green
  if (n.contains('statist')) return const Color(0xFF0277BD); // blue
  if (n.contains('math')) return const Color(0xFF1565C0); // blue darker
  if (n.contains('informatique') || n.contains('tic')) return const Color(0xFF546E7A); // blueGrey
  if (n.contains('science')) return const Color(0xFF512DA8); // deep purple
  if (n.contains('geograph')) return const Color(0xFF2E7D32); // green
  if (n.contains('histoire')) return const Color(0xFF6D4C41); // brown
  if (n.contains('anglais') || n.contains('francais') || n.contains('français')) {
    return const Color(0xFFAD1457); // pink
  }
  if (n.contains('logique') || n.contains('raisonnement') || n.contains('aptitude')) {
    return const Color(0xFF00838F); // cyan dark
  }
  return _Brand.primary; // fallback cohérent
}

class _CycleHeader extends StatelessWidget {
  const _CycleHeader({required this.cycleName});

  final String cycleName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Brand.chipBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Brand.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: _Brand.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycle sélectionné',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _Brand.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cycleName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _Brand.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tuile “Live Quizzes” style (carte blanche bordée, arrondis)
class _SubjectTile extends StatelessWidget {
  final Subject subject;
  final void Function(String chapterName) onOpenChapter;

  const _SubjectTile({
    required this.subject,
    required this.onOpenChapter,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final Color fg = _colorForSubject(subject.name);
    final Color bg = fg.withOpacity(0.14); // fond doux

    return Container(
      decoration: BoxDecoration(
        color: _Brand.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Brand.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              // Icône adaptée à la matière
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconForSubject(subject.name), color: fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subject.name,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          children: [
            for (final chapter in subject.chapters)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: _Brand.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _Brand.border),
                ),
                child: ListTile(
                  leading: Icon(Icons.chevron_right, color: fg), // rappel couleur matière
                  title: Text(chapter.name, style: tt.bodyMedium),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _Brand.textMuted),
                  onTap: () => onOpenChapter(chapter.name),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
