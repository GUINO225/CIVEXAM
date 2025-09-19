import 'dart:async';
import 'package:flutter/foundation.dart'
    show
        TargetPlatform,
        debugPrint,
        debugPrintStack,
        defaultTargetPlatform,
        kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../models/question.dart';
import '../services/scoring.dart';
import '../app/theme.dart';
import '../utils/responsive_utils.dart';

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
  final bool competitionMode;

  const ExamFullScreen({
    super.key,
    required this.questions,
    required this.duration,
    required this.scoring,
    this.title,
    this.showLocalSummary = true,
    this.overridePerQuestionSeconds,
    this.competitionMode = false,
  });

  @override
  State<ExamFullScreen> createState() => _ExamFullScreenState();
}

class _ExamFullScreenState extends State<ExamFullScreen> with WidgetsBindingObserver {
  late List<int?> answers;
  late int remaining;
  Timer? timer;
  PageController? _pageController;
  int _currentIndex = 0;

  bool _submitted = false;
  ExamResult? _lastResult;

  int _exitCount = 0;
  bool _wasPaused = false;

  bool _secureFlagSupported = true;
  bool _secureFlagActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.competitionMode) {
      WidgetsBinding.instance.addObserver(this);
      WakelockPlus.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      if (mounted && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        unawaited(_enableSecureFlag());
      }
      _checkEmulator();
      _pageController = PageController();
    }
    answers = List<int?>.filled(widget.questions.length, null);

    // Base: provided duration
    remaining = widget.duration.inSeconds;

    // NEW: per-question total override (now clamped to 5..10s)
    if (widget.overridePerQuestionSeconds != null && widget.overridePerQuestionSeconds! > 0) {
      final perQ = widget.overridePerQuestionSeconds!.clamp(5, 10);
      remaining = perQ * widget.questions.length;
    }

    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    if (widget.competitionMode) {
      WidgetsBinding.instance.removeObserver(this);
      WakelockPlus.disable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      if (mounted && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        unawaited(_disableSecureFlag());
      }
    }
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _enableSecureFlag() async {
    if (!mounted || kIsWeb || defaultTargetPlatform != TargetPlatform.android || !_secureFlagSupported) {
      return;
    }
    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      _secureFlagActive = true;
    } on MissingPluginException catch (error, stackTrace) {
      _handleMissingPlugin('addFlags', error, stackTrace);
    } catch (error, stackTrace) {
      _logWindowManagerError('addFlags', error, stackTrace);
    }
  }

  Future<void> _disableSecureFlag() async {
    if (!mounted || kIsWeb || defaultTargetPlatform != TargetPlatform.android || !_secureFlagActive) {
      return;
    }
    try {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } on MissingPluginException catch (error, stackTrace) {
      _handleMissingPlugin('clearFlags', error, stackTrace);
    } catch (error, stackTrace) {
      _logWindowManagerError('clearFlags', error, stackTrace);
    } finally {
      _secureFlagActive = false;
    }
  }

  void _handleMissingPlugin(
      String operation, MissingPluginException error, StackTrace stackTrace) {
    _secureFlagSupported = false;
    _secureFlagActive = false;
    debugPrint('FlutterWindowManager $operation not available: ${error.message}');
    debugPrintStack(stackTrace: stackTrace);
  }

  void _logWindowManagerError(
      String operation, Object error, StackTrace stackTrace) {
    debugPrint('FlutterWindowManager $operation failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  void _startTimer() {
    timer?.cancel();
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
        if (widget.competitionMode && remaining <= 10) {
          if (remaining <= 3) {
            HapticFeedback.heavyImpact();
          } else if (remaining <= 5) {
            HapticFeedback.mediumImpact();
          } else {
            HapticFeedback.selectionClick();
          }
        }
      }
    });
  }

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  /// Removes any "Question XX:" prefix from the question text.
  String _cleanQuestion(String q) {
    return q.replaceFirst(
        RegExp(r'^Question\s*\d+[:\.\)]?\s*', caseSensitive: false),
        '');
  }

  void _onAnswer(int index, int choice) {
    setState(() => answers[index] = choice);
    if (widget.competitionMode) {
      if (index < widget.questions.length - 1) {
        _currentIndex = index + 1;
        _pageController?.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else {
        _submit();
      }
    }
  }

  Widget _questionCard(Question item, int i) {
    final mediaQuery = MediaQuery.of(context);
    final scale = computeScaleFactor(mediaQuery);
    final textScaler = MediaQuery.textScalerOf(context);
    final double optionFontSize = scaledFontSize(
      base: 18,
      scale: scale,
      textScaler: textScaler,
      min: 16,
      max: 26,
    );
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: Text('${i + 1}'),
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_cleanQuestion(item.question),
                        style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 8),
            for (int c = 0; c < item.choices.length; c++)
              RadioListTile<int>(
                value: c,
                groupValue: answers[i],
                onChanged: _submitted ? null : (v) => _onAnswer(i, v!),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.choices[c],
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: optionFontSize,
                      ) ??
                      TextStyle(fontSize: optionFontSize),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.competitionMode) return;
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
      timer?.cancel();
    } else if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      _startTimer();
      Future.microtask(_handleResume);
    }
  }

  Future<void> _handleResume() async {
    _exitCount++;
    if (_exitCount == 1) {
      await _showAlert('Attention', 'Sortie détectée. Une nouvelle sortie sera pénalisée.');
    } else if (_exitCount == 2) {
      setState(() {
        remaining -= 30;
        if (remaining < 0) remaining = 0;
      });
      await _showAlert('Pénalité', '30 secondes retirées du temps restant.');
    } else if (_exitCount >= 3) {
      await _showAlert('Exclusion', 'Vous avez quitté l’application trop souvent.');
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  Future<void> _showAlert(String title, String msg) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _checkEmulator() async {
    if (kIsWeb) return;
    final info = DeviceInfoPlugin();
    bool emulator = false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = await info.androidInfo;
      emulator = !android.isPhysicalDevice;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = await info.iosInfo;
      emulator = !ios.isPhysicalDevice;
    }
    if (emulator) {
      Future.microtask(() => _showAlert('Attention', 'Appareil non officiel détecté.'));
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

    await showDialog(
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

    if (widget.competitionMode) {
      Widget content = Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            if (!_submitted)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Chip(
                  label: Text(_format(remaining),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.redAccent.shade100,
                ),
              )
            else
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Chip(label: Text('Terminé')),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: q.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: _questionCard(q[i], i),
                ),
              ),
            ),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / q.length,
              minHeight: 6,
            ),
          ],
        ),
      );
      content = SelectionContainer.disabled(child: content);
      return WillPopScope(onWillPop: () async => false, child: content);
    }

    Widget content = Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            if (!_submitted)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Chip(
                  label: Text(_format(remaining),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.redAccent.shade100,
                ),
              )
            else
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  const Text('Instructions',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                      'Barème: ${widget.scoring}  •  Temps total: ${_format(remaining)}'),
                  const SizedBox(height: 4),
                  const Text(
                      'Répondez à toutes les questions. Le barème négatif s’applique aux mauvaises réponses.'),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: q.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = q[i];
                  return _questionCard(item, i);
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
                            content: const Text(
                                'Quitter l’épreuve mettra fin à l’examen en cours.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Annuler')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Quitter')),
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
      );
    if (widget.competitionMode) {
      content = SelectionContainer.disabled(child: content);
    }
    return WillPopScope(
      onWillPop: () async {
        if (widget.competitionMode) return false;
        if (_submitted) {
          Navigator.of(context).pop(_lastResult);
          return false;
        }
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quitter ?'),
            content: const Text(
                'Quitter l’épreuve mettra fin à l’examen en cours.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Quitter')),
            ],
          ),
        );
        return ok == true;
      },
      child: content,
    );
  }
}
