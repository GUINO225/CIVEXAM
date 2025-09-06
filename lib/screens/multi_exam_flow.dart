import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/scoring.dart';
import '../services/question_loader.dart';
import '../services/history_store.dart';
import '../models/exam_history_entry.dart';
import '../services/question_randomizer.dart';
import '../services/exam_blueprint.dart';
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
/// - Normal -> `null` pour garder la durée officielle de l’épreuve (sec.duration)
/// - Autres -> on utilise sec/question et on calcule un temps total = sec/question × nb de questions
int? secondsPerQuestion(ExamDifficulty d) {
  switch (d) {
    case ExamDifficulty.facile:
      return 90; // 1 min 30 par question
    case ExamDifficulty.normal:
      return null; // garder les durées officielles des épreuves
    case ExamDifficulty.difficile:
      return 45; // 45s par question
    case ExamDifficulty.expert:
      return 30; // 30s par question
  }
}

String _norm(String s) => s.toLowerCase().trim();

List<Question> _filterQuestions(List<Question> all, String subject, String chapter) {
  final s0 = _norm(subject);
  final c0 = _norm(chapter);
  final subjectAliases = {
    'droit (ohada)': 'droit constitutionnel',
    'logique': 'organisation & logique',
  };
  final chapterAliases = {
    'institutions': 'institutions & principes',
    'geographie de la ci': 'côte d’ivoire',
    'geographie de la côte d’ivoire': 'côte d’ivoire',
  };
  final s = subjectAliases[s0] ?? s0;
  final c = chapterAliases[c0] ?? c0;
  final exact = all.where((q) => _norm(q.subject) == s && _norm(q.chapter) == c).toList(growable: false);
  if (exact.isNotEmpty) return exact;
  final bySubject = all.where((q) => _norm(q.subject) == s).toList(growable: false);
  return bySubject;
}

class ExamSection {
  final String title;
  final String subject;
  final String chapter;
  final Duration duration; // durée "officielle" de l’épreuve
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

  static const int PASS_MIN_WEIGHTED = 0;

  @override
  void initState() {
    super.initState();
    sections = [
      ExamSection(
        title: 'Culture Générale',
        subject: 'Culture Générale',
        chapter: 'Côte d’Ivoire',
        duration: const Duration(minutes: 60),
        scoring: const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 2),
        targetCount: ExamBlueprint.cultureGenerale,
      ),
      ExamSection(
        title: 'Aptitude Verbale',
        subject: 'Aptitude Verbale',
        chapter: 'Vocabulaire & règles',
        duration: const Duration(minutes: 60),
        scoring: const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 2),
        targetCount: ExamBlueprint.aptitudeVerbale,
      ),
      ExamSection(
        title: 'Organisation & Logique',
        subject: 'Organisation & Logique',
        chapter: 'Classements & déductions',
        duration: const Duration(minutes: 60),
        scoring: const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 2),
        targetCount: ExamBlueprint.organisationLogique,
      ),
      ExamSection(
        title: 'Aptitude Numérique',
        subject: 'Aptitude Numérique',
        chapter: 'Bases & proportionnalité',
        duration: const Duration(minutes: 60),
        scoring: const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 2),
        targetCount: ExamBlueprint.aptitudeNumerique,
      ),
    ];
    _loadAll();
  }

  Future<void> _loadAll() async {
    final data = await QuestionLoader.loadENA();
    if (!mounted) return;
    setState(() {
      all = data;
      loading = false;
    });
  }

  Future<void> _startFlow() async {
    results.clear();
    abandoned = false;
    final perQ = secondsPerQuestion(_difficulty);

    for (final sec in sections) {
      final pool = _filterQuestions(all, sec.subject, sec.chapter);
      final qs = pickAndShuffle(pool, sec.targetCount);

      // Choisir la durée en fonction de la difficulté
      final Duration effDuration;
      if (perQ == null) {
        // Normal : garder la durée officielle
        effDuration = sec.duration;
      } else {
        // Autres niveaux : durée = secondes/question × nb de questions
        effDuration = Duration(seconds: perQ * qs.length);
      }

      if (!mounted) return;
      final res = await Navigator.push<ExamResult?>(context, MaterialPageRoute(
        builder: (_) => ExamFullScreen(
          questions: qs,
          duration: effDuration,
          scoring: sec.scoring,
          title: 'Épreuve : ${sec.title} • ${difficultyLabel(_difficulty)}',
          showLocalSummary: false,
        ),
      ));
      if (res != null) {
        results.add(res);
      } else {
        // Abandon de la session
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

    for (int i = 0; i < results.length; i++) {
      final sec = sections[i];
      final r = results[i];
      bruts[sec.title] = (bruts[sec.title] ?? 0) + r.rawScore;
      ponders[sec.title] = (ponders[sec.title] ?? 0) + r.weightedScore;
      corrects[sec.title] = (corrects[sec.title] ?? 0) + r.correctCount;
      totals[sec.title] = (totals[sec.title] ?? 0) + r.total;
      totalWeighted += r.weightedScore;
    }

    final bool success = !abandoned && totalWeighted >= PASS_MIN_WEIGHTED;

    final entry = ExamHistoryEntry(
      date: DateTime.now(),
      correctBySubject: corrects,
      totalBySubject: totals,
      scoresBruts: bruts,
      scoresPonderes: ponders,
      totalPondere: totalWeighted,
      success: success,
      abandoned: abandoned, // conservé
    );
    await HistoryStore.add(entry);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(abandoned ? 'Concours abandonné' : 'Résumé du concours — ${difficultyLabel(_difficulty)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in bruts.keys)
              Text('$s — Brut ${bruts[s]} • Pondéré ${ponders[s]} (${corrects[s]}/${totals[s]})'),
            const SizedBox(height: 8),
            Text('Total pondéré : $totalWeighted'),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamHistoryScreen()));
            },
            child: const Text('Voir l’historique'),
          ),
        ],
      ),
    );
  }

  Widget _difficultyPicker() {
    final items = ExamDifficulty.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((d) {
        final selected = _difficulty == d;
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
          avatar: Icon(icon, size: 18),
          label: Text(difficultyLabel(d)),
          selected: selected,
          tooltip: difficultyHint(d),
          onSelected: (_) => setState(() => _difficulty = d),
        );
      }).toList(),
    );
  }

  IconData _iconForSection(String title) {
    switch (title) {
      case 'Culture Générale':
        return Icons.public;
      case 'Aptitude Verbale':
        return Icons.menu_book_outlined;
      case 'Organisation & Logique':
        return Icons.extension;
      case 'Aptitude Numérique':
        return Icons.calculate;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final perQ = secondsPerQuestion(_difficulty);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag),
            SizedBox(width: 8),
            Text('Parcours multi-épreuves ENA'),
          ],
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Niveau de difficulté', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _difficultyPicker(),
                  const SizedBox(height: 12),
                  if (perQ == null)
                    const Text('Mode Normal : timings officiels des épreuves (réaliste).')
                  else
                    Text('Mode ${difficultyLabel(_difficulty)} : ~${perQ}s par question (temps total ajusté automatiquement).'),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        for (final s in sections)
                          ListTile(
                            leading: Icon(_iconForSection(s.title)),
                            title: Text(s.title),
                            subtitle: Text('Barème: ${s.scoring} • Questions visées: ${s.targetCount}'),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startFlow,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Démarrer le parcours'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
