// lib/screens/exam_full_screen.dart
// =======================
// IMPORTS
// =======================
import 'dart:async'; // Pour Timer.periodic (le compte à rebours)
import 'dart:math';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, debugPrintStack, defaultTargetPlatform, kIsWeb; // Utilitaires de plateforme & debug
import 'package:flutter/material.dart'; // Widgets de base
import 'package:flutter/services.dart'; // Haptics + gestion barre système
import 'package:wakelock_plus/wakelock_plus.dart'; // Empêcher la mise en veille en mode compétition
import 'package:flutter_windowmanager/flutter_windowmanager.dart'; // Flag sécurisé (empêche screenshots) Android
import 'package:device_info_plus/device_info_plus.dart'; // Détecter si l’appareil est un émulateur

import '../models/question.dart'; // Modèle Question
import '../services/scoring.dart'; // Calcul de score
import '../services/question_loader.dart';
import '../services/question_history_store.dart';
import '../services/question_randomizer.dart';
import '../services/exam_blueprint.dart';
import '../app/theme.dart'; // Optionnel (ex: thèmes globaux)
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';
import '../utils/responsive_utils.dart'; // Helpers pour tailles de texte responsives

// Ces deux imports sont pour ton bottom nav existant :
import '../widgets/play_bottom_nav_bar.dart'; // Bottom nav custom de ton app
import 'play_screen.dart'; // Écran parent pour faire un pushReplacement quand on quitte l’exam

// =======================
// DATA: Résultat d’examen
// =======================

class _ExamSection {
  final String subject;
  final int questionCount;

  const _ExamSection(this.subject, this.questionCount);
}

const List<_ExamSection> _officialExamSections = <_ExamSection>[
  _ExamSection('Culture Générale', ExamBlueprint.cultureGenerale),
  _ExamSection('Droit Constitutionnel', ExamBlueprint.droitConstitutionnel),
  _ExamSection('Problèmes Économiques & Sociaux', ExamBlueprint.problemesEconomiquesSociaux),
  _ExamSection('Aptitude Numérique', ExamBlueprint.aptitudeNumerique),
  _ExamSection('Aptitude Verbale', ExamBlueprint.aptitudeVerbale),
  _ExamSection('Organisation & Logique', ExamBlueprint.organisationLogique),
];

class OfficialIntroScreen extends StatefulWidget {
  const OfficialIntroScreen({super.key});

  @override
  State<OfficialIntroScreen> createState() => _OfficialIntroScreenState();
}

class _OfficialIntroScreenState extends State<OfficialIntroScreen> {
  static const int _countdownStart = 3;
  static const int _minutesPerSection = 60;

  bool _acceptedRules = false;
  bool _loading = false;
  bool _countdownActive = false;
  int _countdown = _countdownStart;
  Timer? _countdownTimer;
  String? _errorMessage;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _handleStartPressed() {
    if (_loading || _countdownActive) {
      return;
    }
    if (!_acceptedRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci d’accepter les règles avant de commencer.')),
      );
      return;
    }

    setState(() {
      _countdownActive = true;
      _countdown = _countdownStart;
      _errorMessage = null;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        setState(() {
          _countdownActive = false;
          _countdown = _countdownStart;
        });
        unawaited(HapticFeedback.heavyImpact());
        _launchExam();
      } else {
        setState(() => _countdown--);
        HapticFeedback.mediumImpact();
      }
    });
  }

  Future<void> _launchExam() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final all = await QuestionLoader.loadENA();
      if (!mounted) return;

      final questions = await _prepareQuestions(all);
      if (!mounted) return;

      final durationMinutes = _minutesPerSection * _officialExamSections.length;
      final duration = Duration(minutes: durationMinutes);
      const scoring = ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 2);

      final sessionIds = questions.map((q) => q.id);
      unawaited(
        QuestionHistoryStore.addAll(sessionIds).catchError((Object error, StackTrace stackTrace) {
          debugPrint('OfficialIntroScreen: failed to persist history: $error');
          debugPrintStack(stackTrace: stackTrace);
        }),
      );

      final result = await Navigator.of(context).push<ExamResult?>(
        MaterialPageRoute(
          builder: (_) => ExamFullScreen(
            questions: questions,
            duration: duration,
            scoring: scoring,
            title: 'Concours ENA — Simulation',
            competitionMode: true,
            showLocalSummary: true,
          ),
        ),
      );

      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tentative enregistrée — Score pondéré : ${result.weightedScore}',
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('OfficialIntroScreen: unable to start exam: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible de démarrer le concours. Veuillez réessayer.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec du chargement de l’épreuve.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<List<Question>> _prepareQuestions(List<Question> all) async {
    final rng = Random();
    final selected = <Question>[];
    final usedIds = <String>{};

    for (final section in _officialExamSections) {
      if (section.questionCount <= 0) {
        continue;
      }

      final canonical = QuestionLoader.canon(section.subject);
      final pool = all
          .where((q) => QuestionLoader.canon(q.subject) == canonical)
          .toList(growable: false);

      if (pool.isEmpty) {
        throw Exception('Aucune question disponible pour ${section.subject}.');
      }

      final draw = await pickAndShuffle(
        pool,
        section.questionCount,
        dedupeByQuestion: true,
      );

      final sectionSelection = <Question>[];
      for (final q in draw) {
        if (usedIds.add(q.id)) {
          sectionSelection.add(q);
        }
      }

      if (sectionSelection.length < section.questionCount) {
        final remaining = pool.where((q) => !usedIds.contains(q.id)).toList(growable: false);
        remaining.shuffle(rng);
        final needed = section.questionCount - sectionSelection.length;
        sectionSelection.addAll(remaining.take(needed));
        usedIds.addAll(sectionSelection.map((q) => q.id));
      }

      if (sectionSelection.length < section.questionCount) {
        throw Exception('Pas assez de questions pour ${section.subject}.');
      }

      selected.addAll(sectionSelection);
    }

    selected.shuffle(rng);
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalQuestions = _officialExamSections.fold<int>(
      0,
      (sum, section) => sum + section.questionCount,
    );

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        Text(
          'Simulation officielle ENA',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          'Durée : ${_minutesPerSection * _officialExamSections.length} minutes (6 épreuves de 60 min).',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Barème : +1 bonne réponse, 0 sans réponse, −1 mauvaise réponse (coef 2).',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Répartition des questions :',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ..._officialExamSections.map(
          (section) => ListTile(
            leading: const Icon(Icons.book_outlined),
            title: Text(section.subject),
            subtitle: Text('${section.questionCount} questions'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Total : $totalQuestions questions. Préparez votre matériel et installez-vous dans un environnement calme. '
          'Les sorties de l’application déclenchent des avertissements puis des pénalités.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        CheckboxListTile(
          value: _acceptedRules,
          onChanged: (_loading || _countdownActive)
              ? null
              : (value) => setState(() => _acceptedRules = value ?? false),
          title: const Text('Je m’engage à respecter le règlement du concours et à ne pas quitter l’app.'),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: (_loading || _countdownActive) ? null : _handleStartPressed,
          icon: const Icon(Icons.flag),
          label: Text(_loading ? 'Préparation…' : 'Commencer l’épreuve'),
        ),
        if (_loading) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Concours ENA — Introduction')),
      body: Stack(
        children: [
          body,
          if (_countdownActive)
            Positioned.fill(
              child: Container(
                color: theme.colorScheme.scrim.withOpacity(0.65),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    '$_countdown',
                    key: ValueKey<int>(_countdown),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ExamResult {
  final int correctCount;   // Nombre de bonnes réponses
  final int wrongCount;     // Nombre de mauvaises réponses
  final int blankCount;     // Nombre de non-réponses
  final int rawScore;       // Score brut (avant coefficient)
  final int weightedScore;  // Score pondéré (après coefficient)
  final int total;          // Nombre total de questions

  const ExamResult({
    required this.correctCount,
    required this.wrongCount,
    required this.blankCount,
    required this.rawScore,
    required this.weightedScore,
    required this.total,
  });
}

// =======================
// WIDGET: Plein écran d’examen
// =======================
class ExamFullScreen extends StatefulWidget {
  final List<Question> questions; // Liste des questions à afficher
  final Duration duration;        // Durée totale de l’épreuve
  final ExamScoring scoring;      // Barème de notation
  final String? title;            // Titre affiché en header
  final bool showLocalSummary;    // Afficher le résumé local en fin d’épreuve ou non

  /// Si défini (>0), remplace la durée totale par: (sec/par question) × nbQuestions
  /// (clamp entre 5..10 s par question) — utile pour des modes "speed".
  final int? overridePerQuestionSeconds;

  final bool competitionMode; // Active verrouillage, orientation, etc.
  final List<int?>? initialAnswers; // Pré-remplissage de réponses
  final int? initialRemainingSeconds; // Reprise d’un état sauvegardé
  final void Function(int remainingSeconds, List<int?> answers)? onStateChanged; // Callback régulier
  final VoidCallback? onStateCleared; // Callback à la sortie de l’exam

  /// Couleur de marque pour l’épreuve (si null, déduite de la palette active).
  final Color? brandColor;

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
    this.brandColor,
  });

  @override
  State<ExamFullScreen> createState() => _ExamFullScreenState();
}

// =======================
// STATE
// =======================
class _ExamFullScreenState extends State<ExamFullScreen> with WidgetsBindingObserver {
  // --- État logique ---
  late List<int?> answers; // Réponses choisies (index de choix) ou null
  late int remaining;      // Secondes restantes
  Timer? timer;            // Timer du compte à rebours

  // --- Navigation horizontale entre questions ---
  late final PageController _pageController; // Contrôle le PageView
  int _currentIndex = 0;                     // Index de la question courante

  // --- Résultat / Soumission ---
  bool _submitted = false;   // Flag une fois soumis
  ExamResult? _lastResult;   // Résultat calculé

  // --- Discipline mode compétition ---
  int _exitCount = 0;      // Comptage des sorties de l’app
  bool _wasPaused = false; // L’app était en pause ?

  // --- Sécurisation Android ---
  bool _secureFlagSupported = true; // FLAG_SECURE dispo ?
  bool _secureFlagActive = false;   // FLAG_SECURE actif ?

  // --- Couleur de marque ---
  Color _brandColor(BuildContext context) {
    if (widget.brandColor != null) return widget.brandColor!;
    final cfg = DesignBus.notifier.value;
    final palette = playIconColors(cfg.bgPaletteName);
    if (palette.isNotEmpty) {
      return palette.first;
    }
    return Theme.of(context).colorScheme.primary;
  }

  Color _accentColor() {
    final cfg = DesignBus.notifier.value;
    return complementaryColor(cfg.bgPaletteName);
  }

  Color _onBrand(Color brand) {
    final brightness = ThemeData.estimateBrightnessForColor(brand);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  // =======================
  // LIFECYCLE: init / dispose
  // =======================
  @override
  void initState() {
    super.initState();

    // Mode normal: barre système edge-to-edge mais visible
    if (!widget.competitionMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    }

    // Mode compétition: verrouillage + wakelock + FLAG_SECURE (Android)
    if (widget.competitionMode) {
      WidgetsBinding.instance.addObserver(this);
      WakelockPlus.enable(); // garde l’écran allumé
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // plein écran
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // portrait only
      if (mounted && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        unawaited(_enableSecureFlag()); // empêche capture/rec
      }
      _checkEmulator(); // alerte si device non physique
    }

    _pageController = PageController(); // Init du PageView

    // --- État initial des réponses ---
    answers = List<int?>.filled(widget.questions.length, null);
    if (widget.initialAnswers != null) {
      for (int i = 0; i < answers.length && i < widget.initialAnswers!.length; i++) {
        answers[i] = widget.initialAnswers![i]; // copie des réponses sauvegardées
      }
    }

    // --- Durée initiale ---
    remaining = widget.duration.inSeconds;
    if (widget.overridePerQuestionSeconds != null && widget.overridePerQuestionSeconds! > 0) {
      final perQ = widget.overridePerQuestionSeconds!.clamp(5, 10); // borne 5..10
      remaining = perQ * widget.questions.length; // recalcule durée totale
    }
    if (widget.initialRemainingSeconds != null && widget.initialRemainingSeconds! > 0) {
      remaining = widget.initialRemainingSeconds!; // reprise d’un timer sauvegardé
    }

    _startTimer();           // Lance le compte à rebours
    Future.microtask(_notifyStateChanged); // Notifie l’état initial
  }

  @override
  void dispose() {
    timer?.cancel(); // stop timer
    if (widget.competitionMode) {
      WidgetsBinding.instance.removeObserver(this);
      WakelockPlus.disable(); // réautorise veille
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values); // rend toutes les orientations
      if (mounted && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        unawaited(_disableSecureFlag()); // enlève FLAG_SECURE
      }
    }
    _pageController.dispose(); // libère le contrôleur
    super.dispose();
  }

  // Active le FLAG_SECURE (Android) pour bloquer captures d’écran
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

  // Désactive le FLAG_SECURE (Android)
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

  // Gestion d’un plugin manquant (sur certaines plates-formes)
  void _handleMissingPlugin(String operation, MissingPluginException error, StackTrace stackTrace) {
    _secureFlagSupported = false;
    _secureFlagActive = false;
    debugPrint('FlutterWindowManager $operation not available: ${error.message}');
    debugPrintStack(stackTrace: stackTrace);
  }

  // Log propre d’erreurs WindowManager
  void _logWindowManagerError(String operation, Object error, StackTrace stackTrace) {
    debugPrint('FlutterWindowManager $operation failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  // =======================
  // NAV BOTTOM: gestion clics sur la barre du bas
  // =======================
  Future<void> _handleBottomNavSelection(int index) async {
    if (index == 2) return; // index de l’onglet “jeu/exam” actuel → ne rien faire

    // Si on n’a pas soumis, demander confirmation de quitter
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
      if (shouldLeave != true) return;
    }

    // Notifier le parent, puis rediriger vers l’onglet choisi
    widget.onStateCleared?.call();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PlayScreen(initialIndex: index)),
    );
  }

  // Notifie parent: temps restant + copies des réponses
  void _notifyStateChanged() {
    final callback = widget.onStateChanged;
    if (callback == null) return;
    callback(remaining, List<int?>.from(answers));
  }

  // Quitte l’exam en renvoyant un résultat (ou null si abandon)
  void _leaveExam(ExamResult? result) {
    widget.onStateCleared?.call();
    Navigator.of(context).pop(result);
  }

  // Lance/relance le timer 1s
  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_submitted) {
        t.cancel();
        return;
      }
      if (remaining <= 0) {
        _submit(auto: true); // envoie auto quand temps écoulé
      } else {
        setState(() => remaining--); // décrémente
        _notifyStateChanged();       // notifie parent (persist/analytics)
        // Feedback haptique en fin de timer (mode compétition)
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

  // Format mm:ss
  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  // Nettoie l’énoncé s’il commence par “Question 12: ...”
  String _cleanQuestion(String q) {
    return q.replaceFirst(RegExp(r'^Question\s*\d+[:\.\)]?\s*', caseSensitive: false), '');
  }

  // =======================
  // LIFECYCLE app (mode compétition)
  // =======================
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

  // Pénalités si l’utilisateur sort trop de l’app
  Future<void> _handleResume() async {
    _exitCount++;
    if (_exitCount == 1) {
      await _showAlert('Attention', 'Sortie détectée. Une nouvelle sortie sera pénalisée.');
    } else if (_exitCount == 2) {
      setState(() {
        remaining -= 30;               // −30 s
        if (remaining < 0) remaining = 0;
      });
      _notifyStateChanged();
      await _showAlert('Pénalité', '30 secondes retirées du temps restant.');
    } else if (_exitCount >= 3) {
      await _showAlert('Exclusion', 'Vous avez quitté l’application trop souvent.');
      if (mounted) _leaveExam(null);
    }
  }

  // Avertit si appareil non-physique (émulateur)
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

  // Boîte d’alerte générique
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

  // Confirme la soumission s’il reste des questions vides
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
    if (ok != true) throw Exception('cancelled');
  }

  // =======================
  // INTERACTIONS: réponses & navigation
  // =======================

  // Lorsqu’un choix est tapé
  void _onAnswer(int index, int choice) {
    setState(() => answers[index] = choice); // enregistre la réponse
    _notifyStateChanged();                   // notifie parent (persist/analytics)

    if (_submitted) return; // si déjà soumis, ignorer

    // Auto-next : si pas la dernière -> passe à la suivante, sinon soumet
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

  // Bouton "Suivant / Terminer"
  Future<void> _nextOrSubmit() async {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    } else {
      await _submit();
    }
  }

  // Bouton "Précédent"
  Future<void> _prev() async {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  // Soumission finale (auto ou manuelle)
  Future<void> _submit({bool auto = false}) async {
    if (_submitted) return;       // éviter double soumission
    if (!auto) {
      try {
        await _confirmSubmitIfBlanks(); // prévient en cas de blancs
      } catch (_) {
        return;                   // utilisateur a choisi "Continuer" (pas soumettre)
      }
    }

    timer?.cancel(); // stop le timer
    final q = widget.questions;

    // Calcule scores
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

    // Barème
    final raw = widget.scoring.rawScore(correctCount: correct, wrongCount: wrong, blankCount: blank);
    final weighted = widget.scoring.weighted(raw);

    // Stocke résultat
    _lastResult = ExamResult(
      correctCount: correct,
      wrongCount: wrong,
      blankCount: blank,
      rawScore: raw,
      weightedScore: weighted,
      total: q.length,
    );
    setState(() => _submitted = true);

    // Si pas de résumé local → remonte le résultat au parent et quitte
    if (!widget.showLocalSummary) {
      _leaveExam(_lastResult);
      return;
    }

    // Affiche le résumé local
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

  // =======================
  // UI: HEADER
  // =======================
  Widget _header(
      BuildContext context, String title, int step, int total, Color brand, Color onBrand) {
    final mq = MediaQuery.of(context);
    final progress = (step + 1) / total; // progression 0..1

    return SizedBox(
      height: 180 + mq.padding.top, // hauteur header + hauteur encoche
      child: Stack(
        children: [
          // Fond arrondi en bas
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.only(top: mq.padding.top), // laisse l’encoche
              decoration: BoxDecoration(
                color: brand,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
            ),
          ),
          // Ligne supérieure: back + titre + timer
          Positioned(
            top: mq.padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                // Flèche retour (confirme si non soumis)
                IconButton(
                  onPressed: _submitted
                      ? () => _leaveExam(_lastResult)
                      : () async {
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
                  icon: Icon(Icons.arrow_back, color: onBrand),
                ),
                // Titre centré
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: onBrand,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Timer (MM:SS)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: onBrand.withOpacity(.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    _format(remaining),
                    style: TextStyle(color: onBrand, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Barre de progression + "QUESTION X SUR Y" + bouton "Soumettre"
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              children: [
                // Progression fine
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: onBrand.withOpacity(.25),
                  color: onBrand,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Pastille circulaire (anneau)
                    _PieBadge(
                      value: step + 1,
                      total: total,
                      size: 56,
                      foreground: onBrand,
                      background: onBrand.withOpacity(.35),
                    ),
                    const SizedBox(width: 12),
                    // Label FR
                    Expanded(
                      child: Text(
                        'QUESTION ${step + 1} SUR $total',
                        style: TextStyle(
                          color: onBrand.withOpacity(.95),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Bouton "Soumettre" bien visible dans le header
                    OutlinedButton.icon(
                      onPressed: _submitted ? null : () => _submit(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: onBrand,
                        side: BorderSide(color: onBrand.withOpacity(.8)),
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

  // =======================
  // UI: Question + actions bas
  // =======================
  Widget _questionArea(Question q, int index, Color brand, Color onBrand) {
    final mediaQuery = MediaQuery.of(context);
    final scale = computeScaleFactor(mediaQuery);          // facteur device
    final textScaler = MediaQuery.textScalerOf(context);   // facteur accessibilité

    // Taille de l’énoncé (grosse et responsive)
    final double questionTitleSize = scaledFontSize(
      base: 20, scale: scale, textScaler: textScaler, min: 18, max: 26,
    );

    // Taille des choix
    final double optionFontSize =
        scaledFontSize(base: 18, scale: scale, textScaler: textScaler, min: 16, max: 22);

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            // Carte qui occupe tout l’espace dispo (scroll interne si contenu long)
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
                              // Meta: “QUESTION X SUR Y”
                              Text(
                                'QUESTION ${index + 1} SUR ${widget.questions.length}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      letterSpacing: 0.8,
                                      color: onSurface.withOpacity(.55),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              // Énoncé
                              Text(
                                _cleanQuestion(q.question),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: questionTitleSize,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              // Choix (A, B, C, D…)
                              for (int c = 0; c < q.choices.length; c++) ...[
                                _OptionPill(
                                  label: '${String.fromCharCode(65 + c)}. ${q.choices[c]}',
                                  selected: answers[index] == c,
                                  onTap: _submitted ? null : () => _onAnswer(index, c),
                                  fontSize: optionFontSize,
                                  brand: brand,
                                  onBrand: onBrand,
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

            // Barre d’actions en bas (Précédent | Suivant/Terminer)
            // NOTE: on ajoute de la marge en bas si la bottom bar est présente,
            // pour éviter que les boutons soient "collés" au menu.
            SafeArea(
              top: false,
              minimum: EdgeInsets.fromLTRB(0, 12, 0, widget.competitionMode ? 12 : 28),
              child: Row(
                children: [
                  // Précédent
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
                  // Suivant / Terminer
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitted ? null : _nextOrSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: brand,
                        foregroundColor: onBrand,
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

  // =======================
  // BUILD
  // =======================
  @override
  Widget build(BuildContext context) {
    final q = widget.questions;               // questions
    final title = widget.title ?? 'Examen';   // titre fallback

    // Couleurs & contrastes
    final Color brand = _brandColor(context);
    final Brightness brandBrightness = ThemeData.estimateBrightnessForColor(brand);
    final Color onBrand = brandBrightness == Brightness.dark ? Colors.white : Colors.black;
    final Color accent = _accentColor();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color navHighlight = accent.withOpacity(isDark ? 0.32 : 0.20);

    // Status bar (icônes/texte) au-dessus du header
    final Brightness overlayIconBrightness =
        brandBrightness == Brightness.dark ? Brightness.light : Brightness.dark;
    final Brightness overlayStatusBrightness =
        brandBrightness == Brightness.dark ? Brightness.dark : Brightness.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Teinte des icônes de la status bar au-dessus du header coloré
      value: SystemUiOverlayStyle(
        statusBarColor: brand,
        statusBarIconBrightness: overlayIconBrightness,
        statusBarBrightness: overlayStatusBrightness,
      ),
      child: SelectionContainer.disabled(
        child: Scaffold(
          // ⚠️ CLEF: on **n’étend** le body **que** si **pas** de bottom bar
          // → évite que le contenu passe sous le menu quand il est présent
          extendBody: widget.competitionMode,
          extendBodyBehindAppBar: true,

          // Fond global clair/sombre
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF111318)
              : const Color(0xFFF7F8FA),

          // Affiche la bottom bar seulement hors compétition
          bottomNavigationBar: widget.competitionMode
              ? null
              : PlayBottomNavBar(
                  destinations: playNavDestinations,
                  selectedIndex: 2,          // onglet courant
                  backgroundColor: brand,
                  highlightColor: navHighlight,
                  foregroundColor: onBrand,
                  onDestinationSelected: _handleBottomNavSelection,
                ),

          // AppBar technique (hauteur 0) pour avoir un edge-to-edge propre
          appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),

          // Corps: header + PageView des questions
          body: Column(
            children: [
              _header(context, title, _currentIndex, q.length, brand, onBrand),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  // En compétition: on bloque le swipe manuel (seulement auto-next)
                  physics: widget.competitionMode
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemCount: q.length,
                  itemBuilder: (_, i) => _questionArea(q[i], i, brand, onBrand),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================
// SOUS-WIDGET: Option (puce cliquable)
// =======================
class _OptionPill extends StatelessWidget {
  final String label;     // ex: "A. Paris"
  final bool selected;    // true si l’option est choisie
  final VoidCallback? onTap; // callback au tap
  final double fontSize;  // taille du texte
  final Color brand;      // couleur de marque
  final Color onBrand;    // couleur du texte sur marque
  final Color onSurface;  // couleur du texte standard

  const _OptionPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.fontSize,
    required this.brand,
    required this.onBrand,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color unselectedBg = dark ? const Color(0xFF222329) : Colors.white; // fond non sélectionné
    final Color unselectedBorder = const Color(0xFFE0E0E6);                   // bord fin
    final Color bg = selected ? brand : unselectedBg;                          // fond si sélectionné
    final Color fg = selected ? onBrand : onSurface.withOpacity(.9);           // texte

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

// =======================
// SOUS-WIDGET: Pastille circulaire de progression
// =======================
class _PieBadge extends StatelessWidget {
  final int value;        // valeur courante (ex: question 4)
  final int total;        // total (ex: 10)
  final double size;      // diamètre
  final Color foreground; // couleur de la jauge avant
  final Color background; // couleur de l’anneau de fond

  const _PieBadge({
    required this.value,
    required this.total,
    this.size = 56,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / total).clamp(0.0, 1.0); // 0..1
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anneau complet (fond)
          CircularProgressIndicator(
            value: 1,
            strokeWidth: size / 8,
            color: background,
          ),
          // Portion remplie
          CircularProgressIndicator(
            value: pct,
            strokeWidth: size / 8,
            color: foreground,
          ),
          // (On n’affiche pas le texte pour garder l’anneau épuré)
        ],
      ),
    );
  }
}
