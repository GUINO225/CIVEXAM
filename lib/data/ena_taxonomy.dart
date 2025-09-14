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

/// Liste dynamique des matières ENA (remplie à partir du JSON).
List<Subject> subjectsENA = const <Subject>[];

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
