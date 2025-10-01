// lib/screens/multi_exam_flow.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/question.dart';
import '../services/scoring.dart';
import '../services/question_loader.dart';
import '../services/history_store.dart';
import '../models/exam_history_entry.dart';
import '../services/question_randomizer.dart';
import '../services/question_history_store.dart';
import '../services/exam_blueprint.dart';
import '../data/ena_taxonomy.dart';
import '../utils/palette_utils.dart';

import 'exam_full_screen.dart';
import 'exam_history_screen.dart';

enum ExamDifficulty { facile, normal, difficile, expert }

String difficultyLabel(ExamDifficulty d) {
  switch (d) {
    case ExamDifficulty.facile:
      return 'Facile';
    case ExamDifficulty.normal:
      return 'Normal (examen)';
    case ExamDifficulty.difficile:
      return 'Difficile';
    case ExamDifficulty.expert:
      return 'Expert';
  }
}

String difficultyHint(ExamDifficulty d) {
  switch (d) {
    case ExamDifficulty.facile:
      return 'Temps confort (+50% env.)';
    case ExamDifficulty.normal:
      return 'Timing réel de l’examen';
    case ExamDifficulty.difficile:
      return 'Temps serré (−25% env.)';
    case ExamDifficulty.expert:
      return 'Très rapide (−50% env.)';
  }
}

/// Retourne le nombre de secondes par question pour la difficulté donnée.
int? secondsPerQuestion(ExamDifficulty d) {
  switch (d) {
    case ExamDifficulty.facile:
      return 90;
    case ExamDifficulty.normal:
      return null;
    case ExamDifficulty.difficile:
      return 45;
    case ExamDifficulty.expert:
      return 30;
  }
}

// Palette de difficulté (peut rester multicolore si tu veux distinguer les modes)
final Map<ExamDifficulty, Color> _difficultyPalette = <ExamDifficulty, Color>{
  ExamDifficulty.facile: accentColor('forestGreen'),
  ExamDifficulty.normal: accentColor('sereneBlue'),
  ExamDifficulty.difficile: accentColor('civFlag'),
  ExamDifficulty.expert: accentColor('violetRose'),
};

List<Question> _filterQuestions(List<Question> all, String subject, String chapter) {
  final s0 = QuestionLoader.canon(subject);
  final c0 = QuestionLoader.canon(chapter);
  final subjectAliases = {
    QuestionLoader.canon('droit (ohada)'): QuestionLoader.canon('droit constitutionnel'),
    QuestionLoader.canon('logique'): QuestionLoader.canon('organisation & logique'),
  };
  final chapterAliases = {
    QuestionLoader.canon('institutions'): QuestionLoader.canon('institutions & principes'),
    QuestionLoader.canon('geographie de la ci'): QuestionLoader.canon("côte d’Ivoire"),
    QuestionLoader.canon('geographie de la côte d’ivoire'): QuestionLoader.canon("côte d’Ivoire"),
  };
  final s = subjectAliases[s0] ?? s0;
  final c = chapterAliases[c0] ?? c0;
  final exact = all
      .where((q) => QuestionLoader.canon(q.subject) == s && QuestionLoader.canon(q.chapter) == c)
      .toList(growable: false);
  if (exact.isNotEmpty) return exact;
  final bySubject = all.where((q) => QuestionLoader.canon(q.subject) == s).toList(growable: false);
  return bySubject;
}

class ExamSection {
  final String title;
  final String subject;
  final String chapter;
  final Duration duration;
  final ExamScoring scoring;
  final int targetCount;

  ExamSection({
    required this.title,
    required this.subject,
    required this.chapter,
    required this.duration,
    required this.scoring,
    required this.targetCount,
  });
}

class MultiExamFlowScreen extends StatefulWidget {
  const MultiExamFlowScreen({super.key});

  @override
  State<MultiExamFlowScreen> createState() => _MultiExamFlowScreenState();
}

class _MultiExamFlowScreenState extends State<MultiExamFlowScreen> {
  late List<ExamSection> sections;
  final results = <ExamResult>[];
  List<Question> all = const [];
  bool loading = true;
  bool abandoned = false;

  ExamDifficulty _difficulty = ExamDifficulty.normal;

  static const double PASS_MIN_SUCCESS_RATE = 0.5;

  @override
  void initState() {
    super.initState();

    final counts = {
      'Culture Générale': ExamBlueprint.cultureGenerale,
      'Droit Constitutionnel': ExamBlueprint.droitConstitutionnel,
      'Problèmes Économiques & Sociaux': ExamBlueprint.problemesEconomiquesSociaux,
      'Aptitude Numérique': ExamBlueprint.aptitudeNumerique,
      'Aptitude Verbale': ExamBlueprint.aptitudeVerbale,
      'Organisation & Logique': ExamBlueprint.organisationLogique,
    };

    sections = [
      for (final subj in subjectsENA)
        ExamSection(
          title: subj.name,
          subject: subj.name,
          chapter: subj.chapters.first.name,
          duration: const Duration(minutes: 60),
          scoring: const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 2),
          targetCount: counts[subj.name] ?? ExamBlueprint.perSection,
        ),
    ];
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final data = await QuestionLoader.loadENA();
      if (!mounted) return;
      setState(() {
        all = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _startFlow() async {
    results.clear();
    abandoned = false;
    final perQ = secondsPerQuestion(_difficulty);

    await QuestionHistoryStore.clear();

    for (final sec in sections) {
      final pool = _filterQuestions(all, sec.subject, sec.chapter);
      var takeCount = sec.targetCount;
      if (pool.length < sec.targetCount) {
        if (!mounted) return;
        final reason = await ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text('Seulement ${pool.length}/${sec.targetCount} questions disponibles pour ${sec.title}.'),
            action: SnackBarAction(
              label: 'Continuer',
              onPressed: () {},
            ),
          ),
        ).closed;
        if (!mounted) return;
        if (reason != SnackBarClosedReason.action) {
          return;
        }
        takeCount = pool.length;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      List<Question> qs;
      try {
        qs = await pickAndShuffle(
          pool,
          takeCount,
          dedupeByQuestion: true,
        );
      } finally {
        if (mounted) Navigator.pop(context);
      }

      if (qs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Toutes les questions ont été vues.'),
            action: SnackBarAction(
              label: 'Réinitialiser',
              onPressed: () => QuestionHistoryStore.clear(),
            ),
          ),
        );
        return;
      }

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      unawaited(
        QuestionHistoryStore.addAll(qs.map((q) => q.id)).catchError((Object error, _) {
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Échec de l’enregistrement de l’historique des questions.'),
            ),
          );
        }),
      );

      // Durée selon difficulté
      final Duration effDuration =
      (perQ == null) ? sec.duration : Duration(seconds: perQ * qs.length);

      if (!mounted) return;
      final res = await Navigator.push<ExamResult?>(
        context,
        MaterialPageRoute(
          builder: (_) => ExamFullScreen(
            questions: qs,
            duration: effDuration,
            scoring: sec.scoring,
            title: 'Épreuve : ${sec.title} • ${difficultyLabel(_difficulty)}',
            showLocalSummary: false,
            // ---> on propage la couleur #5336C6 dans l’épreuve
            brandColor: const Color(0xFF5336C6),
          ),
        ),
      );

      if (res != null) {
        results.add(res);
      } else {
        abandoned = true;
        break;
      }
    }

    if (!mounted) return;
    _showSummaryAndSave();
  }

  Future<void> _showSummaryAndSave() async {
    final Map<String, int> bruts = {};
    final Map<String, int> ponders = {};
    final Map<String, int> corrects = {};
    final Map<String, int> totals = {};
    int totalWeighted = 0;
    int totalCorrect = 0;
    int totalQuestions = 0;

    for (int i = 0; i < results.length; i++) {
      final sec = sections[i];
      final r = results[i];
      bruts[sec.title] = (bruts[sec.title] ?? 0) + r.rawScore;
      ponders[sec.title] = (ponders[sec.title] ?? 0) + r.weightedScore;
      corrects[sec.title] = (corrects[sec.title] ?? 0) + r.correctCount;
      totals[sec.title] = (totals[sec.title] ?? 0) + r.total;
      totalWeighted += r.weightedScore;
      totalCorrect += r.correctCount;
      totalQuestions += r.total;
    }

    final double successRate = totalQuestions == 0 ? 0 : totalCorrect / totalQuestions;
    final bool success = !abandoned && totalQuestions > 0 && successRate >= PASS_MIN_SUCCESS_RATE;

    final entry = ExamHistoryEntry(
      date: DateTime.now(),
      correctBySubject: corrects,
      totalBySubject: totals,
      scoresBruts: bruts,
      scoresPonderes: ponders,
      totalPondere: totalWeighted,
      success: success,
      abandoned: abandoned,
    );
    await HistoryStore.add(entry);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(abandoned
            ? 'Concours abandonné'
            : 'Résumé du concours — ${difficultyLabel(_difficulty)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in bruts.keys)
              Text('$s — Brut ${bruts[s]} • Pondéré ${ponders[s]} (${corrects[s]}/${totals[s]})'),
            const SizedBox(height: 8),
            Text('Total pondéré : $totalWeighted'),
            Text('Taux de bonnes réponses : ${(successRate * 100).toStringAsFixed(1)} %'),
            Text('Résultat : ${abandoned ? "Abandonné 🟠" : (success ? "Réussi ✅" : "Échoué ❌")}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExamHistoryScreen()),
              );
            },
            child: const Text('Voir l’historique'),
          ),
        ],
      ),
    );
  }

  // === UI helpers ============================================================

  String _formatShort(Duration d) {
    final total = d.inSeconds;
    final m = total ~/ 60;
    final s = total % 60;
    return '${m}m${s.toString().padLeft(2, '0')}s';
  }

  Widget _difficultyPicker(BuildContext context) {
    final items = ExamDifficulty.values;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((d) {
        final selected = _difficulty == d;
        final accent = _difficultyPalette[d] ?? theme.colorScheme.primary;
        final isDark = theme.brightness == Brightness.dark;
        final backgroundColor = accent.withOpacity(isDark ? 0.22 : 0.12);
        final selectedColor = accent.withOpacity(isDark ? 0.32 : 0.20);
        IconData icon;
        switch (d) {
          case ExamDifficulty.facile:
            icon = Icons.sentiment_satisfied_alt;
            break;
          case ExamDifficulty.normal:
            icon = Icons.sentiment_neutral;
            break;
          case ExamDifficulty.difficile:
            icon = Icons.sentiment_dissatisfied;
            break;
          case ExamDifficulty.expert:
            icon = Icons.bolt;
            break;
        }
        return ChoiceChip(
          avatar: Icon(icon, size: 18, color: accent),
          label: Text(difficultyLabel(d)),
          selected: selected,
          tooltip: difficultyHint(d),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          backgroundColor: backgroundColor,
          selectedColor: selectedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          onSelected: (_) => setState(() => _difficulty = d),
        );
      }).toList(),
    );
  }

  IconData _iconForSection(String title) {
    switch (title) {
      case 'Culture Générale':
        return Icons.public;
      case 'Droit Constitutionnel':
        return Icons.account_balance;
      case 'Problèmes Économiques & Sociaux':
        return Icons.bar_chart;
      case 'Aptitude Numérique':
        return Icons.calculate;
      case 'Aptitude Verbale':
        return Icons.menu_book_outlined;
      case 'Organisation & Logique':
        return Icons.extension;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final bool isDark = scheme.brightness == Brightness.dark;

    // === Marque globale : #5336C6 ===
    final Color brand = const Color(0xFF5336C6);
    final Color pageBg = isDark ? const Color(0xFF111318) : const Color(0xFFF7F8FA);
    final Color onPage = isDark ? Colors.white.withOpacity(0.92) : const Color(0xFF1B1B1F);
    final Color cardColor = isDark ? const Color(0xFF1F1F22) : Colors.white;

    final perQ = secondsPerQuestion(_difficulty);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: pageBg,

      // AppBar invisible mais status bar aux couleurs de marque
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: brand,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      body: Stack(
        children: [
          // Bande en haut (derrière l'encoche)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: mq.padding.top, color: brand),
          ),

          // Contenu
          SafeArea(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // ===== HERO CARD =====
                Container(
                  decoration: BoxDecoration(
                    color: brand,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Puce
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Parcours multi-épreuves',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Concours ENA — Simulation complète',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            perQ == null
                                ? 'Mode Normal — timings officiels'
                                : 'Mode ${difficultyLabel(_difficulty)} — ~${perQ}s/question',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _difficultyPicker(context),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ===== Rappel important =====
                Text(
                  'Rappel important',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: onPage,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoBadgeCard(
                  icon: Icons.rule,
                  primary: 'Barème',
                  secondary: '+1 bonne · 0 blanc · −1 mauvaise',
                  brand: brand,
                  onPage: onPage,
                  cardColor: cardColor,
                ),
                const SizedBox(height: 10),
                _InfoBadgeCard(
                  icon: Icons.calculate,
                  primary: 'Coefficient',
                  secondary: '×2 par épreuve',
                  brand: brand,
                  onPage: onPage,
                  cardColor: cardColor,
                ),

                const SizedBox(height: 22),

                // ===== Liste des épreuves =====
                Text(
                  'Épreuves',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: onPage,
                  ),
                ),
                const SizedBox(height: 12),
                for (final s in sections) ...[
                  _SectionTile(
                    icon: _iconForSection(s.title),
                    title: s.title,
                    subtitle:
                    'Questions visées : ${s.targetCount} · Barème ${s.scoring.toStringShort()}',
                    rightLabel: perQ == null
                        ? _formatShort(s.duration)
                        : _formatShort(Duration(seconds: (perQ * s.targetCount))),
                    cardColor: cardColor,
                    brand: brand,
                    onPage: onPage,
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 8),
                // ===== CTA =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startFlow,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Démarrer le parcours'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
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

// === Widgets ================================================================

class _InfoBadgeCard extends StatelessWidget {
  final IconData icon;
  final String primary;
  final String secondary;
  final Color brand;
  final Color onPage;
  final Color cardColor;

  const _InfoBadgeCard({
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.brand,
    required this.onPage,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: brand.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(primary,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: onPage)),
                  const SizedBox(height: 2),
                  Text(secondary, style: TextStyle(color: onPage.withOpacity(0.7))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: brand.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.check, size: 16, color: brand),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String rightLabel;
  final Color cardColor;
  final Color brand;
  final Color onPage;

  const _SectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rightLabel,
    required this.cardColor,
    required this.brand,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: brand.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: onPage)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: onPage.withOpacity(0.7))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: brand.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(
              rightLabel,
              style: TextStyle(fontWeight: FontWeight.w700, color: brand, letterSpacing: .2),
            ),
          ),
        ],
      ),
    );
  }
}

// === Extensions utilitaires ==================================================

extension on ExamScoring {
  String toStringShort() => '+$correct • 0 • $wrong (×$coefficient)';
}
