import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import '../models/question.dart';
import '../services/scoring.dart';
import '../app/theme.dart';

class ExamResult {
  final int correctCount;
  final int wrongCount;
  final int blankCount;
  final int rawScore;
  final int weightedScore;
  final int total;

  const ExamResult({
    required this.correctCount,
    required this.wrongCount,
    required this.blankCount,
    required this.rawScore,
    required this.weightedScore,
    required this.total,
  });
}

class ExamFullScreen extends StatefulWidget {
  final List<Question> questions;
  final Duration duration;
  final ExamScoring scoring;
  final String? title;
  final bool showLocalSummary;
  /// If set (>0), total time = per-question seconds * number of questions.
  /// We hard-limit it to 5..10s now.
  final int? overridePerQuestionSeconds;
  /// Enable anti-cheat protections (full screen, orientation lock, etc.)
  final bool antiCheat;

  const ExamFullScreen({
    super.key,
    required this.questions,
    required this.duration,
    required this.scoring,
    this.title,
    this.showLocalSummary = true,
    this.overridePerQuestionSeconds,
    this.antiCheat = false,
  });

  @override
  State<ExamFullScreen> createState() => _ExamFullScreenState();
}

class _ExamFullScreenState extends State<ExamFullScreen> with WidgetsBindingObserver {
  late List<int?> answers;
  late int remaining;
  Timer? timer;

  bool _submitted = false;
  ExamResult? _lastResult;
  bool _paused = false;
  int _leaveCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.antiCheat) {
      WidgetsBinding.instance.addObserver(this);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      WakelockPlus.enable();
      if (!kIsWeb && Platform.isAndroid) {
        FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      }
    }

    answers = List<int?>.filled(widget.questions.length, null);

    // Base: provided duration
    remaining = widget.duration.inSeconds;

    // NEW: per-question total override (now clamped to 5..10s)
    if (widget.overridePerQuestionSeconds != null && widget.overridePerQuestionSeconds! > 0) {
      final perQ = widget.overridePerQuestionSeconds!.clamp(5, 10);
      remaining = perQ * widget.questions.length;
    }

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_submitted) {
        t.cancel();
        return;
      }
      if (remaining <= 0) {
        _submit(auto: true);
      } else {
        setState(() => remaining--);
      }
    });
  }

  @override
  void dispose() {
    if (widget.antiCheat) {
      WidgetsBinding.instance.removeObserver(this);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      WakelockPlus.disable();
      if (!kIsWeb && Platform.isAndroid) {
        FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    }
    timer?.cancel();
    super.dispose();
  }

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  Future<void> _showAlert(String title, String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.antiCheat || _submitted) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _paused = true;
    } else if (state == AppLifecycleState.resumed && _paused) {
      _paused = false;
      _leaveCount++;
      if (_leaveCount == 1) {
        _showAlert('Attention', 'Sortie de l'application détectée. Prochaine sortie : pénalité.');
      } else if (_leaveCount == 2) {
        setState(() {
          remaining = remaining - 30;
          if (remaining < 0) remaining = 0;
        });
        _showAlert('Pénalité', '30 secondes retirées pour sortie de l'application.');
      } else if (_leaveCount >= 3) {
        _showAlert('Exclusion', 'Épreuve terminée pour tentatives répétées de sortie.');
        _submit(auto: true);
      }
    }
  }

  Future<void> _confirmSubmitIfBlanks() async {
    final blanks = answers.where((e) => e == null).length;
    if (blanks == 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Questions non répondues'),
        content: Text('Il reste $blanks question(s) sans réponse. Soumettre quand même ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuer l’épreuve')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Soumettre')),
        ],
      ),
    );
    if (ok != true) {
      throw Exception('cancelled');
    }
  }

  void _submit({bool auto = false}) async {
    if (_submitted) return;
    if (!auto) {
      try {
        await _confirmSubmitIfBlanks();
      } catch (_) {
        return;
      }
    }

    timer?.cancel();
    final q = widget.questions;
    int correct = 0, wrong = 0, blank = 0;
    for (int i = 0; i < q.length; i++) {
      final sel = answers[i];
      if (sel == null) {
        blank++;
      } else if (sel == q[i].answerIndex) {
        correct++;
      } else {
        wrong++;
      }
    }
    final raw = widget.scoring.rawScore(
      correctCount: correct,
      wrongCount: wrong,
      blankCount: blank,
    );
    final weighted = widget.scoring.weighted(raw);
    _lastResult = ExamResult(
      correctCount: correct,
      wrongCount: wrong,
      blankCount: blank,
      rawScore: raw,
      weightedScore: weighted,
      total: q.length,
    );
    setState(() => _submitted = true);

    if (!widget.showLocalSummary) {
      Navigator.of(context).pop(_lastResult);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(auto ? 'Temps écoulé' : 'Résultats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonnes réponses : $correct'),
            Text('Mauvaises réponses : $wrong'),
            Text('Blancs : $blank'),
            const SizedBox(height: 8),
            Text('Barème : ${widget.scoring}'),
            Text('Score brut : $raw'),
            Text('Score pondéré : $weighted'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(_lastResult);
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions;
    final title = widget.title ?? 'Examen officiel';
    return WillPopScope(
      onWillPop: () async {
        if (!_submitted && widget.antiCheat) {
          return false;
        }
        if (_submitted) {
          Navigator.of(context).pop(_lastResult);
          return false;
        }
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quitter ?'),
            content: const Text('Quitter l’épreuve mettra fin à l’examen en cours.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quitter')),
            ],
          ),
        );
        return ok == true;
      },
      child: widget.antiCheat
          ? SelectionContainer.disabled(child: _buildScaffold(q, title))
          : _buildScaffold(q, title),
    );
  }

  Widget _buildScaffold(List<Question> q, String title) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            if (!_submitted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Chip(
                  label: Text(_format(remaining), style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.redAccent.shade100,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Chip(label: Text('Terminé')),
              ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Instructions', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Barème: ${widget.scoring}  •  Temps total: ${_format(remaining)}'),
                  const SizedBox(height: 4),
                  const Text('Répondez à toutes les questions. Le barème négatif s’applique aux mauvaises réponses.'),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: q.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = q[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: kPrimaryBlue,
                                foregroundColor: Colors.white,
                                child: Text('${i + 1}'),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.question, style: const TextStyle(fontWeight: FontWeight.w600))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (int c = 0; c < item.choices.length; c++)
                            RadioListTile<int>(
                              value: c,
                              groupValue: answers[i],
                              onChanged: _submitted ? null : (v) => setState(() => answers[i] = v),
                              title: Text(item.choices[c]),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (_submitted) {
                          Navigator.of(context).pop(_lastResult);
                          return;
                        }
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Quitter ?'),
                            content: const Text('Quitter l’épreuve mettra fin à l’examen en cours.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quitter')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          Navigator.of(context).pop(null);
                        }
                      },
                      icon: Icon(_submitted ? Icons.check : Icons.close),
                      label: Text(_submitted ? 'Terminer' : 'Quitter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitted ? null : () => _submit(),
                      icon: const Icon(Icons.flag),
                      label: const Text('Soumettre'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
