import 'package:flutter/material.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../models/question.dart';
import '../services/scoring.dart';
import '../models/training_history_entry.dart';
import '../services/training_history_store.dart';
import 'exam_full_screen.dart';

class ChapterListScreen extends StatefulWidget {
  final String subjectName;
  final String chapterName;
  const ChapterListScreen({super.key, required this.subjectName, required this.chapterName});

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  bool _loading = true;
  List<Question> _pool = const [];

  int _perQuestionSeconds = 10;
  final List<int> _secondOptions = const [5, 6, 7, 8, 9, 10];

  int _questionCount = 10;
  final List<int> _countOptions = const [5, 10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await QuestionLoader.loadENA();
    final pool = _filterBy(all, subject: widget.subjectName, chapter: widget.chapterName);
    if (!mounted) return;
    setState(() {
      _pool = pool;
      _loading = false;
    });
  }

  List<Question> _filterBy(List<Question> items, {required String subject, required String chapter}) {
    String norm(String s) => s.toLowerCase().trim();
    final s0 = norm(subject);
    final c0 = norm(chapter);
    final exact = items.where((q) => norm(q.subject) == s0 && norm(q.chapter) == c0).toList(growable: false);
    if (exact.isNotEmpty) return exact;
    return items.where((q) => norm(q.subject) == s0).toList(growable: false);
  }

  Future<void> _start() async {
    if (_pool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune question disponible pour ce module.')));
      return;
    }
    final selected = pickAndShuffle(_pool, _questionCount);
    final totalSeconds = _perQuestionSeconds * selected.length;

    final scoring = const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 1);
    final res = await Navigator.push<ExamResult?>(context, MaterialPageRoute(
      builder: (_) => ExamFullScreen(
        questions: selected,
        duration: Duration(seconds: totalSeconds),
        scoring: scoring,
        title: 'Entraînement — ${widget.subjectName} • ${widget.chapterName}',
        showLocalSummary: true,
      ),
    ));

    if (res != null) {
      final bool success = res.total > 0 && (res.correctCount / res.total) >= 0.5;
      final entry = TrainingHistoryEntry(
        date: DateTime.now(),
        subject: widget.subjectName,
        chapter: widget.chapterName,
        durationMinutes: (totalSeconds / 60).ceil(),
        correct: res.correctCount,
        total: res.total,
        rawScore: res.rawScore,
        weightedScore: res.weightedScore,
        success: success,
        abandoned: false,
      );
      await TrainingHistoryStore.add(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Tentative enregistrée — Validé.' : 'Tentative enregistrée — Échoué.')),
      );
    } else {
      final entry = TrainingHistoryEntry(
        date: DateTime.now(),
        subject: widget.subjectName,
        chapter: widget.chapterName,
        durationMinutes: (totalSeconds / 60).ceil(),
        correct: 0,
        total: selected.length,
        rawScore: 0,
        weightedScore: 0,
        success: false,
        abandoned: true,
      );
      await TrainingHistoryStore.add(entry);
      if (!mounted) return;
      const snack = SnackBar(content: Text('Tentative enregistrée — Abandonné.'));
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('S’entraîner — ${widget.subjectName}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Module : ${widget.chapterName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Temps par question', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _secondOptions.map((s) {
                              final selected = _perQuestionSeconds == s;
                              return ChoiceChip(
                                label: Text('${s}s'),
                                selected: selected,
                                onSelected: (_) => setState(() => _perQuestionSeconds = s),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Text('Nombre de questions', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _countOptions.map((n) {
                              final selected = _questionCount == n;
                              return ChoiceChip(
                                label: Text('$n'),
                                selected: selected,
                                onSelected: (_) => setState(() => _questionCount = n),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Text('Questions dispo pour ce module : ${_pool.length}'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Commencer l’entraînement'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
