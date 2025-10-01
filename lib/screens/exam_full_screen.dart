// lib/screens/exam_full_screen.dart
import 'dart:async';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, debugPrintStack, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../models/question.dart';
import '../services/scoring.dart';
import '../app/theme.dart';
import '../utils/responsive_utils.dart';
import '../widgets/play_bottom_nav_bar.dart';
import 'play_screen.dart';

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

  /// If set (>0), total time = per-question seconds * number of questions (clamped to 5..10s).
  final int? overridePerQuestionSeconds;

  final bool competitionMode;
  final List<int?>? initialAnswers;
  final int? initialRemainingSeconds;
  final void Function(int remainingSeconds, List<int?> answers)? onStateChanged;
  final VoidCallback? onStateCleared;

  /// Couleur de marque (par défaut #5336C6).
  final Color brandColor;

  const ExamFullScreen({
    super.key,
    required this.questions,
    required this.duration,
    required this.scoring,
    this.title,
    this.showLocalSummary = true,
    this.overridePerQuestionSeconds,
    this.competitionMode = false,
    this.initialAnswers,
    this.initialRemainingSeconds,
    this.onStateChanged,
    this.onStateCleared,
    this.brandColor = const Color(0xFF5336C6),
  });

  @override
  State<ExamFullScreen> createState() => _ExamFullScreenState();
}

class _ExamFullScreenState extends State<ExamFullScreen> with WidgetsBindingObserver {
  late List<int?> answers;
  late int remaining;
  Timer? timer;

  late final PageController _pageController;
  int _currentIndex = 0;

  bool _submitted = false;
  ExamResult? _lastResult;

  int _exitCount = 0;
  bool _wasPaused = false;

  bool _secureFlagSupported = true;
  bool _secureFlagActive = false;

  Color get _brand => widget.brandColor;

  @override
  void initState() {
    super.initState();

    if (!widget.competitionMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    }

    if (widget.competitionMode) {
      WidgetsBinding.instance.addObserver(this);
      WakelockPlus.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      if (mounted && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        unawaited(_enableSecureFlag());
      }
      _checkEmulator();
    }

    _pageController = PageController();

    // state
    answers = List<int?>.filled(widget.questions.length, null);
    if (widget.initialAnswers != null) {
      for (int i = 0; i < answers.length && i < widget.initialAnswers!.length; i++) {
        answers[i] = widget.initialAnswers![i];
      }
    }

    remaining = widget.duration.inSeconds;
    if (widget.overridePerQuestionSeconds != null && widget.overridePerQuestionSeconds! > 0) {
      final perQ = widget.overridePerQuestionSeconds!.clamp(5, 10);
      remaining = perQ * widget.questions.length;
    }
    if (widget.initialRemainingSeconds != null && widget.initialRemainingSeconds! > 0) {
      remaining = widget.initialRemainingSeconds!;
    }

    _startTimer();
    Future.microtask(_notifyStateChanged);
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
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _enableSecureFlag() async {
    if (!mounted || kIsWeb || defaultTargetPlatform != TargetPlatform.android || !_secureFlagSupported) return;
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
    if (!mounted || kIsWeb || defaultTargetPlatform != TargetPlatform.android || !_secureFlagActive) return;
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

  void _handleMissingPlugin(String operation, MissingPluginException error, StackTrace stackTrace) {
    _secureFlagSupported = false;
    _secureFlagActive = false;
    debugPrint('FlutterWindowManager $operation not available: ${error.message}');
    debugPrintStack(stackTrace: stackTrace);
  }

  void _logWindowManagerError(String operation, Object error, StackTrace stackTrace) {
    debugPrint('FlutterWindowManager $operation failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  Future<void> _handleBottomNavSelection(int index) async {
    if (index == 2) return;

    if (!_submitted) {
      final shouldLeave = await showDialog<bool>(
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

      if (shouldLeave != true) {
        return;
      }
    }

    widget.onStateCleared?.call();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PlayScreen(initialIndex: index)),
    );
  }

  void _notifyStateChanged() {
    final callback = widget.onStateChanged;
    if (callback == null) return;
    callback(remaining, List<int?>.from(answers));
  }

  void _leaveExam(ExamResult? result) {
    widget.onStateCleared?.call();
    Navigator.of(context).pop(result);
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
        _notifyStateChanged();
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

  String _cleanQuestion(String q) {
    return q.replaceFirst(RegExp(r'^Question\s*\d+[:\.\)]?\s*', caseSensitive: false), '');
  }

  // lifecycle (mode compétition)
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
      _notifyStateChanged();
      await _showAlert('Pénalité', '30 secondes retirées du temps restant.');
    } else if (_exitCount >= 3) {
      await _showAlert('Exclusion', 'Vous avez quitté l’application trop souvent.');
      if (mounted) _leaveExam(null);
    }
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

  Future<void> _showAlert(String title, String msg) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuer')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Soumettre')),
        ],
      ),
    );
    if (ok != true) {
      throw Exception('cancelled');
    }
  }

  // === Auto-next dès qu'on répond ===
  void _onAnswer(int index, int choice) {
    setState(() => answers[index] = choice);
    _notifyStateChanged();

    if (_submitted) return;

    if (index < widget.questions.length - 1) {
      _currentIndex = index + 1;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      _submit(); // dernière question → soumettre
    }
  }

  Future<void> _nextOrSubmit() async {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    } else {
      await _submit();
    }
  }

  Future<void> _prev() async {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  Future<void> _submit({bool auto = false}) async {
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
    final raw = widget.scoring.rawScore(correctCount: correct, wrongCount: wrong, blankCount: blank);
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
      _leaveExam(_lastResult);
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(auto ? 'Temps écoulé' : 'Résultats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonnes réponses : ${_lastResult!.correctCount}'),
            Text('Mauvaises réponses : ${_lastResult!.wrongCount}'),
            Text('Blancs : ${_lastResult!.blankCount}'),
            const SizedBox(height: 8),
            Text('Barème : ${widget.scoring}'),
            Text('Score brut : ${_lastResult!.rawScore}'),
            Text('Score pondéré : ${_lastResult!.weightedScore}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _leaveExam(_lastResult);
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  // ===================== UI =====================

  Widget _header(BuildContext context, String title, int step, int total) {
    final mq = MediaQuery.of(context);
    final brand = _brand;
    final onBrand = Colors.white;
    final progress = (step + 1) / total;

    return SizedBox(
      height: 180 + mq.padding.top,
      child: Stack(
        children: [
          // Bande + arrondi bas
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.only(top: mq.padding.top),
              decoration: BoxDecoration(
                color: brand,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
            ),
          ),
          // Appbar
          Positioned(
            top: mq.padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  onPressed: _submitted ? () => _leaveExam(_lastResult) : () async {
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
                    if (ok == true) _leaveExam(null);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,
                    ),
                  ),
                ),
                // Timer chip
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    _format(remaining),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Progress + libellé FR + bouton Soumettre dans le header
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(.25),
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PieBadge(
                      value: step + 1,
                      total: total,
                      size: 56,
                      foreground: Colors.white,
                      background: Colors.white.withOpacity(.35),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'QUESTION ${step + 1} / $total',
                        style: TextStyle(
                          color: onBrand.withOpacity(.95),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _submitted ? null : () => _submit(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(.8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Soumettre'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Page de question qui occupe **tout l’espace** sous le header.
  Widget _questionArea(Question q, int index) {
    final mediaQuery = MediaQuery.of(context);
    final scale = computeScaleFactor(mediaQuery);
    final textScaler = MediaQuery.textScalerOf(context);

    // Taille de Titre Énoncé (agrandie & réactive)
    final double questionTitleSize = scaledFontSize(
      base: 20, // plus grand qu’avant
      scale: scale,
      textScaler: textScaler,
      min: 18,
      max: 26,
    );

    final double optionFontSize =
    scaledFontSize(base: 18, scale: scale, textScaler: textScaler, min: 16, max: 22);

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final brand = _brand;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            // Carte prend tout l’espace (scroll interne si besoin)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F1F22) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Meta (FR)
                              Text(
                                'QUESTION ${index + 1} / ${widget.questions.length}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  letterSpacing: 0.8,
                                  color: onSurface.withOpacity(.55),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Énoncé — Titre plus grand
                              Text(
                                _cleanQuestion(q.question),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: questionTitleSize,
                                ),
                              ),
                              const SizedBox(height: 12),
                              for (int c = 0; c < q.choices.length; c++) ...[
                                _OptionPill(
                                  label: '${String.fromCharCode(65 + c)}. ${q.choices[c]}',
                                  selected: answers[index] == c,
                                  onTap: _submitted ? null : () => _onAnswer(index, c),
                                  fontSize: optionFontSize,
                                  brand: brand,
                                  onSurface: onSurface,
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Barre d’actions collée en bas — deux boutons (Précédent | Suivant/Terminer)
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_submitted || index == 0) ? null : _prev,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.chevron_left_rounded, size: 26),
                      label: const Text('Précédent'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitted ? null : _nextOrSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: brand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      icon: Icon(
                        index == widget.questions.length - 1
                            ? Icons.check_rounded
                            : Icons.chevron_right_rounded,
                        size: 26,
                      ),
                      label: Text(index == widget.questions.length - 1 ? 'Terminer' : 'Suivant'),
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

  @override
  Widget build(BuildContext context) {
    final q = widget.questions;
    final title = widget.title ?? 'Math Quiz';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _brand,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: SelectionContainer.disabled(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF111318)
              : const Color(0xFFF7F8FA),
          bottomNavigationBar: widget.competitionMode
              ? null
              : PlayBottomNavBar(
                  destinations: playNavDestinations,
                  selectedIndex: 2,
                  backgroundColor: _brand,
                  onDestinationSelected: _handleBottomNavSelection,
                ),
          appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              _header(context, title, _currentIndex, q.length),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: widget.competitionMode
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemCount: q.length,
                  itemBuilder: (_, i) => _questionArea(q[i], i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Sub-widgets ====================

class _OptionPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double fontSize;
  final Color brand;
  final Color onSurface;

  const _OptionPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.fontSize,
    required this.brand,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color unselectedBg = dark ? const Color(0xFF222329) : Colors.white;
    final Color unselectedBorder = const Color(0xFFE0E0E6);
    final Color bg = selected ? brand : unselectedBg;
    final Color fg = selected ? Colors.white : onSurface.withOpacity(.9);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? Colors.transparent : unselectedBorder),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PieBadge extends StatelessWidget {
  final int value;
  final int total;
  final double size;
  final Color foreground;
  final Color background;

  const _PieBadge({
    required this.value,
    required this.total,
    this.size = 56,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / total).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: size / 8,
            color: background,
          ),
          CircularProgressIndicator(
            value: pct,
            strokeWidth: size / 8,
            color: foreground,
          ),
          // numéro non dessiné pour laisser l’anneau propre
        ],
      ),
    );
  }
}
