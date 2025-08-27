// lib/services/question_loader.dart
// -----------------------------------------------------------------------------
// Charge la banque de questions ENA en acceptant **deux schémas JSON** :
//  A) Nouveau schéma (recommandé)  : {id, concours, subject, chapter, difficulty:int, ...}
//  B) Ancien schéma (compatibilité): {subject, chapter, difficulty:'facile|moyen|difficile', ...}
// - Génère un `id` et un `concours` par défaut si absents (concours='ENA').
// - Convertit la difficulté texte → int (facile=1, moyen=2, difficile=3).
// - Sécurise `answerIndex` et `choices`.
// - Fournit des helpers de filtrage simples (subject/chapter).
// -----------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

String _norm(String s) => s.toLowerCase().trim();

class QuestionLoader {
  /// Tente de charger la banque principale puis, en fallback, un échantillon.
  static Future<List<Question>> loadENA() async {
    final paths = <String>[
      'assets/questions/civexam_questions_ena_core.json', // principal
      'assets/questions/ena_sample.json',                 // fallback
    ];

    for (int p = 0; p < paths.length; p++) {
      final path = paths[p];
      try {
        final raw = await rootBundle.loadString(path);
        final decoded = json.decode(raw);
        if (decoded is List) {
          final out = <Question>[];
          for (int i = 0; i < decoded.length; i++) {
            final item = decoded[i];
            if (item is Map<String, dynamic>) {
              final q = _mapToQuestionCompat(item, i);
              if (q.choices.isNotEmpty) {
                out.add(q);
              }
            }
          }
          if (out.isNotEmpty) {
            // OK
            return out;
          }
        }
      } catch (_) {
        // on passe au fichier suivant
      }
    }
    throw Exception('Aucune banque de questions valide trouvée (ENA). Vérifiez les assets déclarés dans pubspec.yaml.');
  }

  /// Convertit `difficulty` (texte/entier) en entier 1..3
  static int _diffToInt(dynamic v) {
    if (v is int) return v;
    final s = (v == null) ? '' : v.toString().toLowerCase().trim();
    switch (s) {
      case 'facile':
        return 1;
      case 'moyen':
      case 'moyenne':
        return 2;
      case 'difficile':
        return 3;
      default:
        return 2;
    }
  }

  static String _str(Map<String, dynamic> m, String key, [String def = '']) {
    final v = m[key];
    return (v == null) ? def : v.toString();
  }

  static List<String> _choices(Map<String, dynamic> m) {
    final v = m['choices'];
    if (v is List) {
      return v.map((e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  static int _safeAnswerIndex(int idx, int length) {
    if (length <= 0) return 0;
    if (idx < 0) return 0;
    if (idx >= length) return length - 1;
    return idx;
  }

  static String _makeId(Map<String, dynamic> m, int i) {
    final subject = _str(m, 'subject', 'ENA');
    final chapter = _str(m, 'chapter', 'GEN');
    final base = '${subject}-${chapter}-${i + 1}';
    return base
        .replaceAll(RegExp(r'[\s]+'), '-')
        .replaceAll(RegExp(r'[^A-Za-z0-9\-]'), '')
        .toUpperCase();
  }

  /// Mapping tolérant (ancien/nouveau schéma)
  static Question _mapToQuestionCompat(Map<String, dynamic> m, int index) {
    final id = _str(m, 'id').trim().isEmpty ? _makeId(m, index) : _str(m, 'id');
    final concours = _str(m, 'concours').trim().isEmpty ? 'ENA' : _str(m, 'concours');
    final subject = _str(m, 'subject');
    final chapter = _str(m, 'chapter');
    final question = _str(m, 'question');
    final choices = _choices(m);
    final difficulty = _diffToInt(m['difficulty']);
    final explanation = m['explanation']?.toString();

    // answerIndex peut être int ou string
    int ai;
    final rawAi = m['answerIndex'];
    if (rawAi is int) {
      ai = rawAi;
    } else {
      ai = int.tryParse(rawAi?.toString() ?? '0') ?? 0;
    }
    ai = _safeAnswerIndex(ai, choices.length);

    return Question(
      id: id,
      concours: concours,
      subject: subject,
      chapter: chapter,
      question: question,
      choices: choices,
      answerIndex: ai,
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // ----------------------
  // Helpers de filtrage
  // ----------------------

  /// Filtre par matière/chapter (valeurs pleines). Renvoie une nouvelle liste.
  static List<Question> whereSubjectChapter(
    List<Question> all, {
    required String subject,
    required String chapter,
  }) {
    final s = _norm(subject);
    final c = _norm(chapter);
    return all.where((q) => _norm(q.subject) == s && _norm(q.chapter) == c).toList(growable: false);
  }

  /// Filtre par texte « value » à l'intérieur de l'intitulé + matière + chapitre.
  static List<Question> filterBy(
    List<Question> all,
    String value, {
    String? subject,
    String? chapter,
  }) {
    final v = _norm(value);
    final s = subject == null ? null : _norm(subject);
    final c = chapter == null ? null : _norm(chapter);
    return all.where((q) {
      if (s != null && _norm(q.subject) != s) return false;
      if (c != null && _norm(q.chapter) != c) return false;
      return _norm(q.question).contains(v) || _norm(q.subject).contains(v) || _norm(q.chapter).contains(v);
    }).toList(growable: false);
  }
}
