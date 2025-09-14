import 'package:diacritic/diacritic.dart';
import '../models/question.dart';

class Subject {
  final String name;
  final List<Chapter> chapters;
  const Subject(this.name, this.chapters);
}

class Chapter {
  final String name;
  const Chapter(this.name);
}

/// Liste des matières ENA.
///
/// Par défaut, elle contient les six modules officiels avec un chapitre
/// initial chacun. Cette liste peut ensuite être reconstruite dynamiquement
/// via [buildSubjectsENA] lorsque les questions sont chargées depuis le JSON.
List<Subject> subjectsENA = const <Subject>[
  Subject('Culture Générale', [Chapter("Côte d'Ivoire")]),
  Subject('Droit Constitutionnel', [Chapter('Institutions & principes')]),
  Subject('Problèmes Économiques & Sociaux', [Chapter('Notions clés')]),
  Subject('Aptitude Numérique', [Chapter('Bases & proportionnalité')]),
  Subject('Aptitude Verbale', [Chapter('Vocabulaire & règles')]),
  Subject('Organisation & Logique', [Chapter('Classements & déductions')]),
];

String _canon(String s) {
  return removeDiacritics(s)
      .toLowerCase()
      .replaceAll(RegExp(r"[’`´‘]"), "'")
      .trim();
}

/// Construit [subjectsENA] à partir de la liste de [questions].
void buildSubjectsENA(List<Question> questions) {
  final Map<String, String> subjectNames = {};
  final Map<String, Map<String, String>> chapterNames = {};

  for (final q in questions) {
    final subjKey = _canon(q.subject);
    final chapKey = _canon(q.chapter);
    if (subjKey.isEmpty || chapKey.isEmpty) continue;
    subjectNames.putIfAbsent(subjKey, () => q.subject);
    final chapters = chapterNames.putIfAbsent(subjKey, () => <String, String>{});
    chapters.putIfAbsent(chapKey, () => q.chapter);
  }

  final list = <Subject>[
    for (final key in subjectNames.keys)
      Subject(
        subjectNames[key]!,
        [
          for (final c in chapterNames[key]!.values)
            Chapter(c),
        ]..sort((a, b) => a.name.compareTo(b.name)),
      ),
  ]..sort((a, b) => a.name.compareTo(b.name));

  subjectsENA = list;
}
