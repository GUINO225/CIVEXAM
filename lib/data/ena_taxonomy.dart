class Subject {
  final String name;
  final List<Chapter> chapters;
  const Subject(this.name, this.chapters);
}

class Chapter {
  final String name;
  const Chapter(this.name);
}

// Aligne les intitulés avec le JSON (6 matières)
const subjectsENA = <Subject>[
  Subject('Culture Générale', [
    Chapter('Côte d’Ivoire'),
  ]),
  Subject('Droit Constitutionnel', [
    Chapter('Institutions & principes'),
  ]),
  Subject('Problèmes Économiques & Sociaux', [
    Chapter('Notions clés'),
  ]),
  Subject('Aptitude Numérique', [
    Chapter('Bases & proportionnalité'),
  ]),
  Subject('Aptitude Verbale', [
    Chapter('Vocabulaire & règles'),
  ]),
  Subject('Organisation & Logique', [
    Chapter('Classements & déductions'),
  ]),
];
