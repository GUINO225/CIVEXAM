import 'dart:async';
import 'package:flutter/material.dart';

import '../services/question_loader.dart';
import '../models/question.dart';
import '../services/scoring.dart';
import '../services/question_randomizer.dart';
import '../services/question_history_store.dart';
import '../models/training_history_entry.dart';
import '../services/training_history_store.dart';
import 'exam_full_screen.dart';
import '../services/ongoing_quiz_store.dart';
import '../widgets/chip_selector.dart';

/// Palette inspirée du design fourni (violets, surfaces très claires).
class _Brand {
  static const primary = Color(0xFF6C5CE7);       // violet principal
  static const primaryDark = Color(0xFF5B4DE1);   // violet plus profond
  static const secondary = Color(0xFF7F6AF8);     // accent
  static const surface = Color(0xFFF7F5FF);       // fond app
  static const card = Color(0xFFFFFFFF);          // cartes blanches
  static const chipBg = Color(0xFFEFEAFF);        // chip non sélectionnée
  static const text = Color(0xFF1E1E28);          // texte principal
  static const textMuted = Color(0xFF6E6B7A);     // texte secondaire
  static const border = Color(0xFFE6E1F9);        // bordure douce
}

class TrainingQuickStartScreen extends StatefulWidget {
  const TrainingQuickStartScreen({super.key});

  @override
  State<TrainingQuickStartScreen> createState() => _TrainingQuickStartScreenState();
}

class _TrainingQuickStartScreenState extends State<TrainingQuickStartScreen> {
  int _perQuestionSeconds = 10; // 5..10 s/question via l’UI
  int _questionCount = 10;      // nombre de questions
  bool _loading = false;

  final List<int> _secondOptions = const [5, 6, 7, 8, 9, 10];
  final List<int> _countOptions  = const [5, 10, 15, 20];

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      final List<Question> all = await QuestionLoader.loadENA();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final List<Question> selected = await pickAndShuffle(
        all,
        _questionCount,
        dedupeByQuestion: true,
      );

      if (mounted) Navigator.pop(context);

      final proceed = await _handleShortDraw(selected, _questionCount);
      if (!proceed) return;

      unawaited(
        QuestionHistoryStore.addAll(selected.map((q) => q.id)).catchError((Object _, __) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de l’enregistrement de l’historique des questions.')),
          );
        }),
      );

      final totalSeconds = _perQuestionSeconds * selected.length;
      final scoring = const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 1);
      final title = 'Entraînement (${_perQuestionSeconds}s/question)';

      final quickState = OngoingQuickQuizState(
        title: title,
        questionIds: selected.map((q) => q.id).toList(growable: false),
        answers: List<int?>.filled(selected.length, null, growable: false),
        remainingSeconds: totalSeconds,
      );
      await OngoingQuickQuizStore.save(quickState);

      final startTime = DateTime.now();

      final res = await Navigator.push<ExamResult?>(
        context,
        MaterialPageRoute(
          builder: (_) => ExamFullScreen(
            questions: selected,
            duration: Duration(seconds: totalSeconds),
            scoring: scoring,
            title: title,
            showLocalSummary: true,
            initialAnswers: quickState.answers,
            initialRemainingSeconds: quickState.remainingSeconds,
            onStateChanged: (remaining, answers) {
              unawaited(
                OngoingQuickQuizStore.save(
                  quickState.copyWith(remainingSeconds: remaining, answers: answers),
                ),
              );
            },
            onStateCleared: () {
              unawaited(OngoingQuickQuizStore.clear());
            },
          ),
        ),
      );

      final completedAt = DateTime.now();

      if (res != null) {
        await OngoingQuickQuizStore.saveLastResult(
          QuickQuizSummary(
            title: title,
            completedAt: completedAt,
            correctAnswers: res.correctCount,
            totalQuestions: res.total,
          ),
        );
      } else {
        await OngoingQuickQuizStore.clearLastResult();
      }
      await OngoingQuickQuizStore.clear();

      final elapsedSeconds = completedAt.difference(startTime).inSeconds;

      if (res != null) {
        final bool success = res.total > 0 && (res.correctCount / res.total) >= 0.5; // ≥ 50%
        final entry = TrainingHistoryEntry(
          date: DateTime.now(),
          subject: 'Entraînement (mix)',
          chapter: 'Général',
          durationMinutes: (elapsedSeconds / 60).ceil(),
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
          subject: 'Entraînement (mix)',
          chapter: 'Général',
          durationMinutes: (elapsedSeconds / 60).ceil(),
          correct: 0,
          total: selected.length,
          rawScore: 0,
          weightedScore: 0,
          success: false,
          abandoned: true,
        );
        await TrainingHistoryStore.add(entry);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tentative enregistrée — Abandonné.')),
        );
      }
    } catch (e) {
      if (mounted) {
        // ferme toute modale éventuelle
        Navigator.popUntil(context, (route) => route.isFirst || route is! PopupRoute);
      }
      unawaited(OngoingQuickQuizStore.clear());
      unawaited(OngoingQuickQuizStore.clearLastResult());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du lancement de l’entraînement : $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _handleShortDraw(List<Question> selected, int requested) async {
    if (selected.length >= requested) return true;
    if (!mounted) return false;

    if (selected.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Historique épuisé'),
          content: const Text('Toutes les questions ont déjà été vues. Réinitialiser l’historique pour recommencer.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(_, null), child: const Text('Fermer')),
            TextButton(
              onPressed: () {
                QuestionHistoryStore.clear();
                Navigator.pop(_, null);
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        ),
      );
      return false;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Commencer ?'),
        content: Text('Vous avez déjà vu la plupart des questions — ${selected.length}/$requested disponibles.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              QuestionHistoryStore.clear();
              Navigator.pop(_, false);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(onPressed: () => Navigator.pop(_, true), child: const Text('Continuer')),
        ],
      ),
    );
    return proceed == true;
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);

    // Thème local qui impose la palette violette du design fourni
    final themed = base.copyWith(
      scaffoldBackgroundColor: _Brand.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _Brand.primary,
        brightness: base.brightness,
      ).copyWith(
        primary: _Brand.primary,
        secondary: _Brand.secondary,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _Brand.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: _Brand.text,
        ),
        backgroundColor: _Brand.chipBg,
        selectedColor: _Brand.primary,
        secondarySelectedColor: _Brand.primary,
        showCheckmark: false,
        side: const BorderSide(color: _Brand.border),
      ),
      dividerColor: _Brand.border,
    );

    final total = Duration(seconds: _perQuestionSeconds * _questionCount);
    String two(int x) => x.toString().padLeft(2, '0');
    final totalLabel = '${two(total.inMinutes)}:${two(total.inSeconds % 60)}';

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entraînement'),
          // actions supprimées (avatar "M" retiré)
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // Header en dégradé violet (avatar "M" retiré)
              const _GradientHeader(
                title: 'Bonjour 👋',
                subtitle: 'Prêt(e) pour un rapide entraînement ?',
              ),
              const SizedBox(height: 16),

              // --- Blocs "Réglages rapides" et "Featured" SUPPRIMÉS ---

              // Section chips : Temps par question
              _SectionCard(
                title: 'Temps par question',
                icon: Icons.timer_outlined,
                child: ChipSelector<int>(
                  options: _secondOptions,
                  selected: _perQuestionSeconds,
                  onSelected: (s) => setState(() => _perQuestionSeconds = s),
                  spacing: 10,
                  runSpacing: 10,
                  labelBuilder: (s) => '${s}s',
                ),
              ),
              const SizedBox(height: 12),

              // Section chips : Nombre de questions
              _SectionCard(
                title: 'Nombre de questions',
                icon: Icons.confirmation_number_outlined,
                child: ChipSelector<int>(
                  options: _countOptions,
                  selected: _questionCount,
                  onSelected: (n) => setState(() => _questionCount = n),
                  spacing: 10,
                  runSpacing: 10,
                  labelBuilder: (n) => '$n',
                ),
              ),
              const SizedBox(height: 12),

              _InfoTile(
                icon: Icons.schedule,
                label: 'Temps total estimé',
                value: totalLabel,
              ),
            ],
          ),
        ),

        // Bouton d’action centré
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _start,
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_arrow),
            label: Text(_loading ? 'Chargement…' : 'Commencer maintenant'),
          ),
        ),

        // Nav bar fantôme pour laisser respirer le CTA
        bottomNavigationBar: const SizedBox(height: 12),
      ),
    );
  }
}

/// ----- Petits widgets inspirés du design -----

class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _GradientHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Brand.primary, _Brand.primaryDark],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: tt.bodyMedium!.copyWith(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: tt.titleSmall!.copyWith(color: Colors.white70, letterSpacing: .3)),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: tt.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Avatar "M" retiré
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: _Brand.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Brand.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.circle, size: 8, color: _Brand.primary),
            const SizedBox(width: 8),
            Icon(icon, color: _Brand.primary),
            const SizedBox(width: 8),
            Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: _Brand.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Brand.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: _Brand.secondary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: tt.bodyMedium?.copyWith(color: _Brand.textMuted))),
          Text(value, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
