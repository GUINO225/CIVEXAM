import json
import random
from collections import defaultdict

TARGET_TOTAL = 5000
RANDOM_SEED = 20240601

random.seed(RANDOM_SEED)

INPUT_PATH = "assets/questions/civexam_questions_ena_core.json"

SUBJECT_TARGET_ADDITIONS = {
    "Culture Générale": 150,
    "Droit Constitutionnel": 150,
    "Problèmes Économiques & Sociaux": 1000,
    "Aptitude Numérique": 1600,
    "Aptitude Verbale": 1400,
    "Organisation & Logique": 543,
}

SUBJECT_PREFIX = {
    "Culture Générale": "CG-GEN",
    "Droit Constitutionnel": "DC-CL",
    "Problèmes Économiques & Sociaux": "PE-NS",
    "Aptitude Numérique": "AN-BP",
    "Aptitude Verbale": "AV-VR",
    "Organisation & Logique": "OL-CD",
}

SUBJECT_CHAPTER = {
    "Culture Générale": "Afrique & Monde",
    "Droit Constitutionnel": "Institutions & principes",
    "Problèmes Économiques & Sociaux": "Notions clés",
    "Aptitude Numérique": "Bases & proportionnalité",
    "Aptitude Verbale": "Vocabulaire & règles",
    "Organisation & Logique": "Classements & déductions",
}


def load_questions(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def dump_questions(path: str, questions):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)
        f.write("\n")


def next_identifier(prefix: str, counters: dict[str, int]) -> str:
    counters[prefix] += 1
    return f"{prefix}-{counters[prefix]:04d}"


AFRICAN_CAPITALS = [
    ("Côte d’Ivoire", "Yamoussoukro"),
    ("Burkina Faso", "Ouagadougou"),
    ("Ghana", "Accra"),
    ("Nigeria", "Abuja"),
    ("Sénégal", "Dakar"),
    ("Mali", "Bamako"),
    ("Niger", "Niamey"),
    ("Guinée", "Conakry"),
    ("Sierra Leone", "Freetown"),
    ("Libéria", "Monrovia"),
    ("Togo", "Lomé"),
    ("Bénin", "Porto-Novo"),
    ("Cameroun", "Yaoundé"),
    ("Gabon", "Libreville"),
    ("Congo", "Brazzaville"),
    ("République démocratique du Congo", "Kinshasa"),
    ("Angola", "Luanda"),
    ("Kenya", "Nairobi"),
    ("Tanzanie", "Dodoma"),
    ("Ouganda", "Kampala"),
    ("Rwanda", "Kigali"),
    ("Burundi", "Gitega"),
    ("Éthiopie", "Addis-Abeba"),
    ("Somalie", "Mogadiscio"),
    ("Érythrée", "Asmara"),
    ("Djibouti", "Djibouti"),
    ("Soudan", "Khartoum"),
    ("Soudan du Sud", "Djouba"),
    ("Égypte", "Le Caire"),
    ("Libye", "Tripoli"),
    ("Tunisie", "Tunis"),
    ("Algérie", "Alger"),
    ("Maroc", "Rabat"),
    ("Mauritanie", "Nouakchott"),
    ("Guinée-Bissau", "Bissau"),
    ("Cap-Vert", "Praia"),
    ("Gambie", "Banjul"),
    ("Tchad", "N’Djamena"),
    ("République centrafricaine", "Bangui"),
    ("Guinée équatoriale", "Malabo"),
    ("São Tomé-et-Principe", "São Tomé"),
    ("Zimbabwe", "Harare"),
    ("Zambie", "Lusaka"),
    ("Botswana", "Gaborone"),
    ("Namibie", "Windhoek"),
    ("Lesotho", "Maseru"),
    ("Eswatini", "Mbabane"),
    ("Mozambique", "Maputo"),
    ("Malawi", "Lilongwe"),
    ("Madagascar", "Antananarivo"),
    ("Seychelles", "Victoria"),
    ("Comores", "Moroni"),
    ("Île Maurice", "Port-Louis"),
    ("Afrique du Sud", "Pretoria"),
]

GLOBAL_CAPITALS = [
    ("France", "Paris"),
    ("Canada", "Ottawa"),
    ("États-Unis", "Washington"),
    ("Chine", "Pékin"),
    ("Japon", "Tokyo"),
    ("Inde", "New Delhi"),
    ("Brésil", "Brasilia"),
    ("Argentine", "Buenos Aires"),
    ("Mexique", "Mexico"),
    ("Allemagne", "Berlin"),
    ("Italie", "Rome"),
    ("Espagne", "Madrid"),
    ("Portugal", "Lisbonne"),
    ("Royaume-Uni", "Londres"),
    ("Russie", "Moscou"),
    ("Turquie", "Ankara"),
    ("Arabie saoudite", "Riyad"),
    ("Qatar", "Doha"),
    ("Émirats arabes unis", "Abou Dabi"),
    ("Israël", "Jérusalem"),
    ("Palestine", "Ramallah"),
    ("Iran", "Téhéran"),
    ("Irak", "Bagdad"),
    ("Syrie", "Damas"),
    ("Liban", "Beyrouth"),
    ("Jordanie", "Amman"),
    ("Pakistan", "Islamabad"),
    ("Afghanistan", "Kaboul"),
    ("Bangladesh", "Dacca"),
    ("Thaïlande", "Bangkok"),
    ("Vietnam", "Hanoï"),
    ("Philippines", "Manille"),
    ("Indonésie", "Jakarta"),
    ("Malaisie", "Kuala Lumpur"),
    ("Singapour", "Singapour"),
    ("Corée du Sud", "Séoul"),
    ("Australie", "Canberra"),
    ("Nouvelle-Zélande", "Wellington"),
    ("Grèce", "Athènes"),
    ("Pays-Bas", "Amsterdam"),
    ("Belgique", "Bruxelles"),
    ("Suisse", "Berne"),
    ("Suède", "Stockholm"),
    ("Norvège", "Oslo"),
    ("Finlande", "Helsinki"),
    ("Danemark", "Copenhague"),
    ("Pologne", "Varsovie"),
    ("Hongrie", "Budapest"),
    ("Autriche", "Vienne"),
    ("Tchéquie", "Prague"),
    ("Slovaquie", "Bratislava"),
    ("Roumanie", "Bucarest"),
    ("Bulgarie", "Sofia"),
    ("Serbie", "Belgrade"),
    ("Croatie", "Zagreb"),
    ("Slovénie", "Ljubljana"),
    ("Ukraine", "Kyiv"),
    ("Biélorussie", "Minsk"),
    ("Géorgie", "Tbilissi"),
    ("Arménie", "Erevan"),
    ("Kazakhstan", "Astana"),
    ("Ouzbékistan", "Tachkent"),
    ("Turkménistan", "Achgabat"),
    ("Kirghizistan", "Bichkek"),
    ("Tadjikistan", "Douchanbé"),
    ("Mongolie", "Oulan-Bator"),
    ("Népal", "Katmandou"),
    ("Bhoutan", "Thimphou"),
    ("Laos", "Vientiane"),
    ("Cambodge", "Phnom Penh"),
    ("Myanmar", "Naypyidaw"),
    ("Sri Lanka", "Sri Jayawardenapura Kotte"),
    ("Maldives", "Malé"),
    ("Yémen", "Sanaa"),
    ("Oman", "Mascate"),
    ("Koweït", "Koweït"),
    ("Bahreïn", "Manama"),
    ("Chili", "Santiago"),
    ("Pérou", "Lima"),
    ("Colombie", "Bogota"),
    ("Venezuela", "Caracas"),
    ("Équateur", "Quito"),
    ("Bolivie", "Sucre"),
    ("Paraguay", "Asuncion"),
    ("Uruguay", "Montevideo"),
    ("Guyana", "Georgetown"),
    ("Suriname", "Paramaribo"),
    ("Costa Rica", "San José"),
    ("Panama", "Panama"),
    ("Guatemala", "Guatemala"),
    ("Honduras", "Tegucigalpa"),
    ("Nicaragua", "Managua"),
    ("Salvador", "San Salvador"),
    ("Belize", "Belmopan"),
    ("Cuba", "La Havane"),
    ("Haïti", "Port-au-Prince"),
    ("République dominicaine", "Saint-Domingue"),
]

CAPITAL_DATA = AFRICAN_CAPITALS + GLOBAL_CAPITALS


def format_number(value: float) -> str:
    if abs(value - round(value)) < 1e-9:
        return str(int(round(value)))
    return f"{value:.2f}".replace(".", ",")


def pick_other_items(pool, count, exclude_index):
    indices = [i for i in range(len(pool)) if i != exclude_index]
    random.shuffle(indices)
    return [pool[i][1] for i in indices[:count]]


def generate_culture_question(index: int, prefix: str, counters, used_questions: set[str]):
    country, capital = CAPITAL_DATA[index % len(CAPITAL_DATA)]
    ask_capital = (index // len(CAPITAL_DATA)) % 2 == 0
    if ask_capital:
        correct = capital
        distractors = pick_other_items(CAPITAL_DATA, 3, index % len(CAPITAL_DATA))
        random.shuffle(distractors)
        choices = distractors + [correct]
        random.shuffle(choices)
        answer = choices.index(correct)
        question = f"Quelle est la capitale de {country} ?"
        explanation = f"La capitale officielle de {country} est {capital}."
    else:
        correct = country
        others = [item[0] for item in CAPITAL_DATA if item[0] != country]
        random.shuffle(others)
        choices = others[:3] + [correct]
        random.shuffle(choices)
        answer = choices.index(correct)
        question = f"Dans quel pays se trouve la ville de {capital} ?"
        explanation = f"{capital} est la capitale du pays {country}."
    if question in used_questions:
        raise ValueError("Duplicate culture question generated")
    return {
        "subject": "Culture Générale",
        "chapter": SUBJECT_CHAPTER["Culture Générale"],
        "difficulty": 1,
        "question": question,
        "choices": choices,
        "answerIndex": answer,
        "explanation": explanation,
    }
CONSTITUTIONAL_CONCEPTS = [
    {
        "concept": "Séparation des pouvoirs",
        "definition": "la répartition des fonctions législative, exécutive et judiciaire pour éviter la concentration du pouvoir",
        "scenario": "le Parlement vote la loi, le Président la promulgue et les juges l’appliquent sans interférence",
        "distractors": ["Souveraineté nationale", "Contrôle de constitutionnalité", "Décentralisation"],
    },
    {
        "concept": "Souveraineté nationale",
        "definition": "le pouvoir politique émane du peuple qui le délègue à ses représentants",
        "scenario": "les députés exercent le mandat confié par l’ensemble des citoyens",
        "distractors": ["Séparation des pouvoirs", "État de droit", "Élection indirecte"],
    },
    {
        "concept": "État de droit",
        "definition": "la soumission de l’État et des citoyens aux règles juridiques établies",
        "scenario": "un ministre doit respecter une décision de justice devenue définitive",
        "distractors": ["Gouvernement parlementaire", "Pouvoir réglementaire", "Référendum"],
    },
    {
        "concept": "Contrôle de constitutionnalité",
        "definition": "la vérification de la conformité des lois à la Constitution",
        "scenario": "le Conseil constitutionnel annule une loi contraire aux droits fondamentaux",
        "distractors": ["Motion de censure", "Ordonnance", "Droit de grâce"],
    },
    {
        "concept": "Irresponsabilité présidentielle",
        "definition": "le chef de l’État n’est pas politiquement responsable devant le Parlement",
        "scenario": "les députés ne peuvent destituer le Président qu’en cas de haute trahison",
        "distractors": ["Responsabilité gouvernementale", "Immunité parlementaire", "Haute cour"],
    },
    {
        "concept": "Responsabilité gouvernementale",
        "definition": "le gouvernement doit conserver la confiance du Parlement pour rester en fonction",
        "scenario": "une motion de censure est adoptée et le Premier ministre démissionne",
        "distractors": ["Irresponsabilité présidentielle", "Pouvoir réglementaire", "Inviolabilité du domicile"],
    },
    {
        "concept": "Référendum",
        "definition": "la consultation directe du corps électoral sur un texte",
        "scenario": "les citoyens approuvent par vote la révision constitutionnelle proposée",
        "distractors": ["Plébiscite", "Motion de confiance", "Décret-loi"],
    },
    {
        "concept": "Liberté d’association",
        "definition": "le droit de créer librement des groupements pour défendre des intérêts communs",
        "scenario": "des étudiants fondent une organisation reconnue sans autorisation préalable",
        "distractors": ["Liberté de presse", "Liberté de conscience", "Droit de pétition"],
    },
    {
        "concept": "Droits de la défense",
        "definition": "les garanties accordées à toute personne poursuivie pour faire valoir ses arguments",
        "scenario": "un accusé est assisté d’un avocat et peut consulter son dossier",
        "distractors": ["Présomption d’innocence", "Principe du contradictoire", "Nullité de procédure"],
    },
    {
        "concept": "Présomption d’innocence",
        "definition": "toute personne est considérée innocente tant que sa culpabilité n’est pas établie",
        "scenario": "un citoyen ne peut être emprisonné avant jugement sans motif légal",
        "distractors": ["Droits de la défense", "Non bis in idem", "Sursis"],
    },
    {
        "concept": "Non bis in idem",
        "definition": "nul ne peut être jugé ou puni deux fois pour les mêmes faits",
        "scenario": "après un acquittement définitif, un nouveau procès est interdit",
        "distractors": ["Présomption d’innocence", "Double degré de juridiction", "Amnistie"],
    },
    {
        "concept": "Principe du contradictoire",
        "definition": "chaque partie doit pouvoir discuter les arguments et preuves de l’autre",
        "scenario": "le juge reporte l’audience pour que la défense prenne connaissance d’une pièce nouvelle",
        "distractors": ["Publicité des débats", "Oralité de la procédure", "Célérité de la justice"],
    },
    {
        "concept": "Publicité des débats",
        "definition": "les audiences sont en principe ouvertes au public",
        "scenario": "un journaliste assiste librement à une audience correctionnelle",
        "distractors": ["Huis clos", "Principe du contradictoire", "Secret de l’instruction"],
    },
    {
        "concept": "Habeas corpus",
        "definition": "la garantie d’être présenté rapidement devant un juge pour contester une détention",
        "scenario": "une personne arrêtée exige de voir un magistrat dans les délais légaux",
        "distractors": ["Mandat de dépôt", "Assignation à résidence", "Libération conditionnelle"],
    },
    {
        "concept": "Décentralisation",
        "definition": "le transfert de compétences administratives à des collectivités territoriales autonomes",
        "scenario": "une région gère son budget et décide de ses priorités d’aménagement",
        "distractors": ["Déconcentration", "Fédéralisme", "Tutelle administrative"],
    },
    {
        "concept": "Déconcentration",
        "definition": "la délégation de compétences de l’État à ses services locaux",
        "scenario": "un préfet représente l’État dans une circonscription pour appliquer les lois",
        "distractors": ["Décentralisation", "Fédéralisme", "Régionalisation"],
    },
    {
        "concept": "Fédéralisme",
        "definition": "l’organisation politique fondée sur la répartition constitutionnelle des compétences entre État fédéral et entités fédérées",
        "scenario": "les États fédérés disposent de constitutions propres sous le contrôle d’une constitution fédérale",
        "distractors": ["Unitarisme", "Décentralisation", "Régionalisme"],
    },
    {
        "concept": "Supériorité de la Constitution",
        "definition": "toute norme juridique doit être conforme à la Constitution",
        "scenario": "une loi contraire à la Constitution est annulée par la juridiction compétente",
        "distractors": ["Hiérarchie des normes", "Révision constitutionnelle", "Promulgation"],
    },
    {
        "concept": "Révision constitutionnelle",
        "definition": "la procédure permettant de modifier la Constitution",
        "scenario": "le Parlement réuni en Congrès approuve une modification de la loi fondamentale",
        "distractors": ["Réforme législative", "Référendum", "Abrogation"],
    },
    {
        "concept": "Pouvoir réglementaire",
        "definition": "la faculté pour l’exécutif de fixer des règles générales d’application des lois",
        "scenario": "un décret précise les modalités d’exécution d’une loi votée",
        "distractors": ["Pouvoir constituant", "Pouvoir législatif", "Arrêté municipal"],
    },
    {
        "concept": "Hiérarchie des normes",
        "definition": "l’organisation pyramidale des règles juridiques où chaque niveau est subordonné au niveau supérieur",
        "scenario": "un arrêté ministériel ne peut contredire un décret ou une loi",
        "distractors": ["Contrôle parlementaire", "Principe d’égalité", "Supériorité des traités"],
    },
    {
        "concept": "Bloc de constitutionnalité",
        "definition": "l’ensemble des textes et principes de valeur constitutionnelle servant de référence au contrôle",
        "scenario": "le Conseil constitutionnel se fonde sur la Déclaration de 1789 pour censurer une loi",
        "distractors": ["Bloc de légalité", "Jurisprudence", "Décret d’application"],
    },
    {
        "concept": "Protection des minorités parlementaires",
        "definition": "les garanties permettant aux groupes minoritaires de participer au contrôle de l’exécutif",
        "scenario": "un cinquième des députés saisit le Conseil constitutionnel d’une loi votée",
        "distractors": ["Majorité absolue", "Vote bloqué", "Ordonnance"],
    },
    {
        "concept": "Inviolabilité du domicile",
        "definition": "la protection constitutionnelle contre les visites domiciliaires arbitraires",
        "scenario": "une perquisition doit être autorisée par un magistrat compétent",
        "distractors": ["Secret de la correspondance", "Liberté d’aller et venir", "Liberté de réunion"],
    },
    {
        "concept": "Liberté de presse",
        "definition": "le droit de publier et de diffuser des informations sans censure préalable",
        "scenario": "un journal critique le gouvernement sans être sanctionné",
        "distractors": ["Secret professionnel", "Droit à l’image", "Droit de réponse"],
    },
    {
        "concept": "Liberté religieuse",
        "definition": "la faculté de choisir et pratiquer sa religion ou de n’en pratiquer aucune",
        "scenario": "l’État garantit l’accès aux lieux de culte pour toutes les confessions",
        "distractors": ["Laïcité", "Liberté d’expression", "Liberté syndicale"],
    },
    {
        "concept": "Liberté syndicale",
        "definition": "le droit de créer des syndicats et d’y adhérer pour défendre des intérêts professionnels",
        "scenario": "des travailleurs fondent une union sans autorisation préalable",
        "distractors": ["Droit de grève", "Liberté d’association", "Liberté de réunion"],
    },
    {
        "concept": "Droit de grève",
        "definition": "la faculté pour les travailleurs de cesser collectivement le travail pour faire valoir des revendications",
        "scenario": "les agents d’un service public déposent un préavis et cessent le travail",
        "distractors": ["Lock-out", "Liberté de réunion", "Liberté syndicale"],
    },
    {
        "concept": "Liberté d’aller et venir",
        "definition": "le droit de circuler librement sur le territoire national et de le quitter",
        "scenario": "un citoyen se déplace sans avoir à solliciter d’autorisation",
        "distractors": ["Liberté d’établissement", "Liberté économique", "Droit d’asile"],
    },
    {
        "concept": "Droit d’asile",
        "definition": "la protection accordée par l’État à un étranger persécuté dans son pays",
        "scenario": "un journaliste menacé obtient l’asile après instruction de sa demande",
        "distractors": ["Naturalisation", "Extradition", "Double nationalité"],
    },
    {
        "concept": "Citoyenneté",
        "definition": "l’ensemble des droits et devoirs attachés à l’appartenance à une communauté politique",
        "scenario": "un citoyen ivoirien participe aux élections nationales",
        "distractors": ["Résidence", "Nationalité", "Personnalité juridique"],
    },
]

CONSTITUTIONAL_TEMPLATES = [
    "Quel principe constitutionnel est décrit par l’affirmation suivante : {definition} ?",
    "Quel principe se manifeste lorsque {scenario} ?",
    "Quel concept juridique garantit que {definition} ?",
    "À quel principe renvoie la situation suivante : {scenario} ?",
    "Quel est le nom du principe correspondant à cette idée : {definition} ?",
]


def generate_constitution_question(index: int, prefix: str, counters, used_questions: set[str]):
    concept = CONSTITUTIONAL_CONCEPTS[index % len(CONSTITUTIONAL_CONCEPTS)]
    template = CONSTITUTIONAL_TEMPLATES[(index // len(CONSTITUTIONAL_CONCEPTS)) % len(CONSTITUTIONAL_TEMPLATES)]
    question = template.format(definition=concept["definition"], scenario=concept["scenario"])
    if question in used_questions:
        raise ValueError("Duplicate constitutional question generated")
    choices = concept["distractors"] + [concept["concept"]]
    random.shuffle(choices)
    answer = choices.index(concept["concept"])
    explanation = f"Il s’agit du principe de {concept['concept']} : {concept['definition']}."
    return {
        "subject": "Droit Constitutionnel",
        "chapter": SUBJECT_CHAPTER["Droit Constitutionnel"],
        "difficulty": 2,
        "question": question,
        "choices": choices,
        "answerIndex": answer,
        "explanation": explanation,
    }
PERCENTAGES = [5, 6, 7, 8, 9, 10, 12, 15, 18, 20, 24, 25, 30, 35, 40]


def generate_numeric_question(_: int, prefix: str, counters, used_questions: set[str]):
    template = random.choice(["percent_increase", "percent_decrease", "proportion", "average", "sequence"])
    if template == "percent_increase":
        base = random.randrange(80, 480, 5)
        pct = random.choice(PERCENTAGES)
        value = base * (100 + pct) / 100
        correct = format_number(value)
        offsets = [-pct / 2, pct / 3, pct]
        distractors = [format_number(base * (100 + pct + off) / 100) for off in offsets]
        question = f"Un indicateur vaut {base} et augmente de {pct} %. Quelle est sa nouvelle valeur ?"
        explanation = f"Nouvelle valeur = {base} × (1 + {pct}/100) = {correct}."
    elif template == "percent_decrease":
        base = random.randrange(120, 600, 10)
        pct = random.choice([6, 8, 9, 12, 15, 18, 21, 24])
        value = base * (100 - pct) / 100
        correct = format_number(value)
        distractors = [format_number(base * (100 - pct + shift) / 100) for shift in (-pct / 2, pct / 3, pct / 4)]
        question = f"Une dépense passe de {base} à la suite d’une baisse de {pct} %. Quelle est la nouvelle valeur ?"
        explanation = f"Valeur finale = {base} × (1 - {pct}/100) = {correct}."
    elif template == "proportion":
        a = random.randrange(2, 9)
        b = random.randrange(3, 12)
        c = random.randrange(20, 90, 5)
        x = c * b / a
        correct = format_number(x)
        distractors = [format_number(c * (b + delta) / a) for delta in (-2, 2, 4)]
        question = f"Complétez la proportion : {a} / {b} = {c} / x. Quelle est la valeur de x ?"
        explanation = f"x = {c} × {b} ÷ {a} = {correct}."
    elif template == "average":
        weights = [random.randrange(2, 6), random.randrange(2, 6), random.randrange(2, 6)]
        scores = [random.randrange(8, 19), random.randrange(8, 19), random.randrange(8, 19)]
        total_weight = sum(weights)
        weighted_sum = sum(w * s for w, s in zip(weights, scores))
        avg = weighted_sum / total_weight
        correct = format_number(avg)
        distractors = [format_number((weighted_sum + adj) / total_weight) for adj in (-weights[0], weights[1], weights[2])]
        question = (
            "Trois indicateurs de pondérations {w1}, {w2} et {w3} obtiennent les notes {s1}, {s2} et {s3}. "
            "Quelle est la moyenne pondérée ?"
        ).format(
            w1=weights[0], w2=weights[1], w3=weights[2], s1=scores[0], s2=scores[1], s3=scores[2]
        )
        explanation = (
            "Moyenne = ({w1}×{s1} + {w2}×{s2} + {w3}×{s3}) / ({total}) = {avg}."
        ).format(
            w1=weights[0], s1=scores[0], w2=weights[1], s2=scores[1], w3=weights[2], s3=scores[2], total=total_weight, avg=correct
        )
    else:  # sequence
        start = random.randrange(3, 20)
        step = random.randrange(2, 12)
        length = 5
        sequence = [start + step * i for i in range(length)]
        correct = format_number(sequence[-1] + step)
        distractors = [format_number(sequence[-1] + delta) for delta in (step + 2, step - 3, step * 2)]
        terms = ", ".join(str(x) for x in sequence)
        question = f"Suite arithmétique : {terms}, … Quel est le terme suivant ?"
        explanation = f"La suite progresse de {step}. Terme suivant = {sequence[-1]} + {step} = {correct}."
    choices = distractors + [correct]
    random.shuffle(choices)
    answer = choices.index(correct)
    return {
        "subject": "Aptitude Numérique",
        "chapter": SUBJECT_CHAPTER["Aptitude Numérique"],
        "difficulty": 2,
        "question": question,
        "choices": choices,
        "answerIndex": answer,
        "explanation": explanation,
    }


def generate_economic_question(_: int, prefix: str, counters, used_questions: set[str]):
    template = random.choice(["budget_share", "growth_rate", "productivity", "inflation", "index"])
    if template == "budget_share":
        total = random.randrange(400, 1200, 20)
        percent = random.choice([12, 15, 18, 20, 22, 24, 28, 30, 32, 35])
        value = total * percent / 100
        correct = format_number(value)
        variants = [p for p in [percent + 6, percent - 4, percent + 10, percent - 6] if p > 0]
        random.shuffle(variants)
        distractors = [format_number(total * p / 100) for p in variants[:3]]
        question = f"Un budget annuel de {total} millions consacre {percent} % à la santé. Quelle somme est affectée à ce poste ?"
        explanation = f"Montant = {total} × {percent} % = {correct} millions."
    elif template == "growth_rate":
        base = random.randrange(80, 260, 5)
        final = random.randrange(base + 10, base + 120, 5)
        rate = (final - base) * 100 / base
        correct = format_number(rate)
        distractors = [format_number(rate + delta) for delta in (-5, 4, 8)]
        question = f"La production d’une PME passe de {base} à {final} tonnes. Quel est le taux de croissance ?"
        explanation = f"Taux = ({final} - {base}) / {base} × 100 = {correct} %."
    elif template == "productivity":
        workers = random.randrange(15, 60, 5)
        output = random.randrange(600, 1800, 50)
        productivity = output / workers
        correct = format_number(productivity)
        distractors = [format_number((output + delta) / workers) for delta in (-100, 80, 150)]
        question = f"Une coopérative emploie {workers} personnes et produit {output} unités. Quelle est la productivité moyenne par personne ?"
        explanation = f"Productivité = {output} ÷ {workers} = {correct} unités par personne."
    elif template == "inflation":
        price0 = random.randrange(120, 360, 10)
        inflation = random.choice([2.5, 3.2, 4.5, 5.1, 6.4, 7.8])
        price1 = price0 * (1 + inflation / 100)
        correct = format_number(price1)
        distractors = [format_number(price0 * (1 + inflation / 100 + delta)) for delta in (-0.02, 0.03, 0.05)]
        question = f"Un panier de biens coûte {price0}. Avec une inflation de {inflation} %, quel sera son prix l’année suivante ?"
        explanation = f"Prix actualisé = {price0} × (1 + {inflation}/100) = {correct}."
    else:
        index0 = random.randrange(90, 120)
        variation = random.choice([3, 4, 5, 6, 7, 8])
        index1 = index0 + variation
        base = random.randrange(2015, 2020)
        year = base + 1
        correct = format_number(index1)
        distractors = [format_number(index0 + variation + delta) for delta in (-4, 2, 5)]
        question = f"L’indice des prix vaut {index0} en {base}. Il progresse de {variation} points en {year}. Quelle est la nouvelle valeur de l’indice ?"
        explanation = f"Nouvel indice = {index0} + {variation} = {correct}."
    choices = distractors + [correct]
    random.shuffle(choices)
    answer = choices.index(correct)
    return {
        "subject": "Problèmes Économiques & Sociaux",
        "chapter": SUBJECT_CHAPTER["Problèmes Économiques & Sociaux"],
        "difficulty": 2,
        "question": question,
        "choices": choices,
        "answerIndex": answer,
        "explanation": explanation,
    }
PRONOUNS = [
    ("Je", "1s"),
    ("Tu", "2s"),
    ("Il", "3s"),
    ("Nous", "1p"),
    ("Vous", "2p"),
    ("Ils", "3p"),
]

PRONOUN_CONTEXTS = {
    "Je": [
        "mes dossiers avant la réunion",
        "la situation calmement",
        "les consignes à haute voix",
        "la décision finale avec prudence",
        "mes objectifs chaque matin",
        "ma famille le week-end",
    ],
    "Tu": [
        "ton avis en toute franchise",
        "les messages importants à l’équipe",
        "souvent des questions pertinentes",
        "la bonne réponse sans hésiter",
        "le dossier dès l’aube",
        "les visiteurs avec sourire",
    ],
    "Il": [
        "le rapport de synthèse chaque vendredi",
        "toujours ses collègues avant d’agir",
        "la stratégie auprès du comité",
        "les risques avec attention",
        "les ressources disponibles",
        "la réunion avec ponctualité",
    ],
    "Nous": [
        "les résultats du trimestre",
        "nos partenaires régulièrement",
        "une solution adaptée",
        "les données chaque semaine",
        "les options avec rigueur",
        "les priorités de l’équipe",
    ],
    "Vous": [
        "les procédures avec sérieux",
        "une approche participative",
        "le projet avec méthode",
        "des retours constructifs",
        "la réunion stratégique",
        "les chiffres clés",
    ],
    "Ils": [
        "leurs missions avec efficacité",
        "les demandes urgentes",
        "les formations nécessaires",
        "la feuille de route",
        "le plan de relève",
        "les objectifs communs",
    ],
}

REGULAR_ER_VERBS = [
    "parler",
    "travailler",
    "chanter",
    "étudier",
    "jouer",
    "regarder",
    "penser",
    "préparer",
    "aimer",
    "apporter",
    "accompagner",
    "organiser",
    "planifier",
    "collecter",
    "arriver",
    "terminer",
    "lancer",
    "animer",
    "adapter",
    "explorer",
    "illustrer",
    "réviser",
    "partager",
    "présenter",
    "construire",
    "encadrer",
    "valoriser",
    "déployer",
    "clarifier",
    "structurer",
    "optimiser",
    "affirmer",
    "coordonner",
    "calculer",
    "observer",
    "collecter",
    "fédérer",
    "notifier",
    "classer",
]

REGULAR_IR_VERBS = [
    "finir",
    "choisir",
    "grandir",
    "réussir",
    "applaudir",
    "nourrir",
    "réfléchir",
    "agir",
    "bâtir",
    "unir",
    "investir",
    "fleurir",
    "avertir",
    "guérir",
    "abolir",
    "blanchir",
    "établir",
    "ralentir",
    "franchir",
    "bondir",
]

REGULAR_RE_VERBS = [
    "vendre",
    "attendre",
    "répondre",
    "entendre",
    "descendre",
    "correspondre",
    "rendre",
    "étendre",
    "défendre",
    "confondre",
    "suspendre",
    "répandre",
    "dépendre",
    "fondre",
    "tendre",
    "prétendre",
    "surprendre",
    "reprendre",
    "apprendre",
    "comprendre",
]

IRREGULAR_PRESENT = {
    "être": {"1s": "suis", "2s": "es", "3s": "est", "1p": "sommes", "2p": "êtes", "3p": "sont"},
    "avoir": {"1s": "ai", "2s": "as", "3s": "a", "1p": "avons", "2p": "avez", "3p": "ont"},
    "aller": {"1s": "vais", "2s": "vas", "3s": "va", "1p": "allons", "2p": "allez", "3p": "vont"},
    "faire": {"1s": "fais", "2s": "fais", "3s": "fait", "1p": "faisons", "2p": "faites", "3p": "font"},
    "venir": {"1s": "viens", "2s": "viens", "3s": "vient", "1p": "venons", "2p": "venez", "3p": "viennent"},
    "pouvoir": {"1s": "peux", "2s": "peux", "3s": "peut", "1p": "pouvons", "2p": "pouvez", "3p": "peuvent"},
    "vouloir": {"1s": "veux", "2s": "veux", "3s": "veut", "1p": "voulons", "2p": "voulez", "3p": "veulent"},
    "devoir": {"1s": "dois", "2s": "dois", "3s": "doit", "1p": "devons", "2p": "devez", "3p": "doivent"},
    "savoir": {"1s": "sais", "2s": "sais", "3s": "sait", "1p": "savons", "2p": "savez", "3p": "savent"},
    "voir": {"1s": "vois", "2s": "vois", "3s": "voit", "1p": "voyons", "2p": "voyez", "3p": "voient"},
    "prendre": {"1s": "prends", "2s": "prends", "3s": "prend", "1p": "prenons", "2p": "prenez", "3p": "prennent"},
}

IRREGULAR_VERBS = list(IRREGULAR_PRESENT.keys())

VERB_BANK = [
    *( (verb, "er") for verb in REGULAR_ER_VERBS ),
    *( (verb, "ir") for verb in REGULAR_IR_VERBS ),
    *( (verb, "re") for verb in REGULAR_RE_VERBS ),
    *( (verb, "irr") for verb in IRREGULAR_VERBS ),
]


def conjugate_present(verb: str, group: str, pronoun_code: str) -> str:
    if group == "er":
        stem = verb[:-2]
        endings = {"1s": "e", "2s": "es", "3s": "e", "1p": "ons", "2p": "ez", "3p": "ent"}
        return stem + endings[pronoun_code]
    if group == "ir":
        stem = verb[:-2]
        endings = {"1s": "is", "2s": "is", "3s": "it", "1p": "issons", "2p": "issez", "3p": "issent"}
        return stem + endings[pronoun_code]
    if group == "re":
        stem = verb[:-2]
        endings = {"1s": "s", "2s": "s", "3s": "", "1p": "ons", "2p": "ez", "3p": "ent"}
        return stem + endings[pronoun_code]
    forms = IRREGULAR_PRESENT[verb]
    return forms[pronoun_code]


def all_present_forms(verb: str, group: str) -> dict[str, str]:
    return {code: conjugate_present(verb, group, code) for _, code in PRONOUNS}


VERBAL_PROMPTS = [
    "Quelle forme du verbe « {verb} » complète correctement la phrase : « {pronoun} ___ {context}. » ?",
    "Choisissez la conjugaison juste du verbe « {verb} » dans la phrase : « {pronoun} ___ {context}. »",
    "Complétez : « {pronoun} ___ {context} » avec la forme correcte de « {verb} » au présent."
]


def generate_verbal_question(index: int, prefix: str, counters, used_questions: set[str]):
    verb, group = VERB_BANK[index % len(VERB_BANK)]
    pronoun, pronoun_code = PRONOUNS[(index // len(VERB_BANK)) % len(PRONOUNS)]
    context_list = PRONOUN_CONTEXTS[pronoun]
    context = context_list[index % len(context_list)]
    template = VERBAL_PROMPTS[(index // (len(VERB_BANK) * len(PRONOUNS))) % len(VERBAL_PROMPTS)]
    correct = conjugate_present(verb, group, pronoun_code)
    forms = all_present_forms(verb, group)
    distractors_pool = []
    for code, form in forms.items():
        if code == pronoun_code:
            continue
        if form == correct:
            continue
        if form not in distractors_pool:
            distractors_pool.append(form)
    stem = correct[:-1] if len(correct) > 1 else correct
    filler_candidates = [
        f"{stem}{suffix}" for suffix in ["s", "z", "ons", "ez", "ait", "er"]
    ]
    for candidate in filler_candidates:
        if len(distractors_pool) >= 3:
            break
        if candidate != correct and candidate not in distractors_pool:
            distractors_pool.append(candidate)
    random.shuffle(distractors_pool)
    choices = distractors_pool[:3] + [correct]
    random.shuffle(choices)
    answer = choices.index(correct)
    question = template.format(verb=verb, pronoun=pronoun, context=context)
    if question in used_questions:
        raise ValueError("Duplicate verbal question generated")
    explanation = (
        f"Au présent, pour le pronom {pronoun}, le verbe « {verb} » se conjugue « {correct} »."
    )
    return {
        "subject": "Aptitude Verbale",
        "chapter": SUBJECT_CHAPTER["Aptitude Verbale"],
        "difficulty": 1,
        "question": question,
        "choices": choices,
        "answerIndex": answer,
        "explanation": explanation,
    }
ALPHABET = {chr(ord('A') + i): i + 1 for i in range(26)}
LOGIC_WORDS = [
    "CIV",
    "NATION",
    "DROIT",
    "SERVICE",
    "PEUPLE",
    "UNION",
    "LOI",
    "JUSTICE",
    "ECOLE",
    "EXAMEN",
    "STATUT",
    "VALEUR",
    "CITOYEN",
    "PROJET",
    "ETHIQUE",
]

DAYS = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]


def sum_word(word: str) -> int:
    return sum(ALPHABET[ch] for ch in word.upper() if ch in ALPHABET)


def generate_logic_question(_: int, prefix: str, counters, used_questions: set[str]):
    template = random.choice(["sequence", "alpha", "calendar", "matrix", "alternating"])
    if template == "sequence":
        start = random.randrange(4, 15)
        diff1 = random.randrange(2, 6)
        diff2 = random.randrange(6, 12)
        seq = [start, start + diff1, start + diff1 + diff2, start + diff1 + diff2 + diff1, start + diff1 + diff2 + diff1 + diff2]
        correct = seq[-1] + diff1
        distractors = [correct + diff for diff in (-3, 2, 5)]
        question = (
            f"Dans la suite {seq[0]}, {seq[1]}, {seq[2]}, {seq[3]}, {seq[4]}, quel nombre vient ensuite si l’on alterne +{diff1} et +{diff2} ?"
        )
        explanation = f"On alterne +{diff1} puis +{diff2}. Après {seq[4]}, on ajoute +{diff1} pour obtenir {correct}."
    elif template == "alpha":
        word = random.choice(LOGIC_WORDS)
        total = sum_word(word)
        distractors = [total + delta for delta in (-4, 3, 5)]
        question = (
            "On attribue à chaque lettre sa position dans l’alphabet (A=1, B=2, …). Quelle est la valeur du mot « {word} » ?"
        ).format(word=word)
        correct = total
        explanation = f"Somme des positions des lettres de « {word} » = {total}."
    elif template == "calendar":
        start_day = random.choice(DAYS)
        offset = random.randrange(9, 45)
        idx = DAYS.index(start_day)
        correct_day = DAYS[(idx + offset) % 7]
        distractors = [DAYS[(idx + offset + shift) % 7] for shift in (-2, 1, 3)]
        question = f"Si une réunion est programmée un {start_day} et reportée de {offset} jours, quel jour de la semaine aura-t-elle lieu ?"
        explanation = f"{offset} jours correspondent à {offset % 7} jours après {start_day}, donc le rendez-vous tombe un {correct_day}."
        correct = correct_day
    elif template == "matrix":
        base = random.randrange(2, 6)
        mult = random.randrange(3, 7)
        grid = [[(i + 1) * (j + 1) * base for j in range(3)] for i in range(3)]
        missing_row = random.randrange(3)
        missing_col = random.randrange(3)
        correct = grid[missing_row][missing_col] * mult
        distractors = [correct + base, correct - base, correct + mult]
        question = (
            "Dans une grille, chaque valeur est le produit de sa ligne, de sa colonne et du facteur {base}. "
            "Si l’on multiplie ensuite la case ({r}, {c}) par {mult}, quelle valeur obtient-on ?"
        ).format(base=base, r=missing_row + 1, c=missing_col + 1, mult=mult)
        explanation = (
            f"Valeur de base = {grid[missing_row][missing_col]}. Après multiplication par {mult}, on obtient {correct}."
        )
    else:
        start = random.randrange(12, 50, 2)
        ratio = random.choice([0.5, 1.5, 2, 2.5])
        addition = random.randrange(3, 12)
        value = start * ratio + addition
        correct = format_number(value)
        distractors = [format_number(start * ratio + addition + delta) for delta in (-3, 2, 5)]
        question = (
            f"Un mécanisme logique applique ×{ratio} puis +{addition} à un nombre de départ {start}. Quel est le résultat final ?"
        )
        explanation = f"Opération : {start} × {ratio} + {addition} = {correct}."
    if template in {"sequence", "alpha", "matrix"}:
        choices = [format_number(d) if isinstance(d, float) else str(d) for d in distractors] + [str(correct)]
    elif template == "calendar":
        choices = distractors + [correct]
    else:
        choices = distractors + [correct]
    random.shuffle(choices)
    if template in {"sequence", "alpha", "matrix"}:
        correct_value = str(correct) if template != "alternating" else correct
    else:
        correct_value = correct
    answer = choices.index(str(correct) if template in {"sequence", "alpha", "matrix"} else correct)
    return {
        "subject": "Organisation & Logique",
        "chapter": SUBJECT_CHAPTER["Organisation & Logique"],
        "difficulty": 2,
        "question": question,
        "choices": choices,
        "answerIndex": answer,
        "explanation": explanation,
    }
GENERATOR_BY_SUBJECT = {
    "Culture Générale": generate_culture_question,
    "Droit Constitutionnel": generate_constitution_question,
    "Problèmes Économiques & Sociaux": generate_economic_question,
    "Aptitude Numérique": generate_numeric_question,
    "Aptitude Verbale": generate_verbal_question,
    "Organisation & Logique": generate_logic_question,
}


def main():
    questions = load_questions(INPUT_PATH)
    existing_ids = {q["id"] for q in questions}
    used_questions = {q["question"] for q in questions}

    counters = {prefix: 1000 for prefix in SUBJECT_PREFIX.values()}
    added_counts = defaultdict(int)
    new_entries = []

    for subject, target in SUBJECT_TARGET_ADDITIONS.items():
        generator = GENERATOR_BY_SUBJECT[subject]
        prefix = SUBJECT_PREFIX[subject]
        count = 0
        index = 0
        attempts = 0
        while count < target:
            entry = generator(index, prefix, counters, used_questions)
            question_text = entry["question"]
            if question_text in used_questions:
                index += 1
                attempts += 1
                if attempts > target * 10:
                    raise RuntimeError(f"Impossible de générer suffisamment de questions pour {subject}")
                continue
            identifier = next_identifier(prefix, counters)
            while identifier in existing_ids:
                identifier = next_identifier(prefix, counters)
            entry.update({
                "id": identifier,
                "concours": "ENA",
            })
            new_entries.append(entry)
            used_questions.add(question_text)
            existing_ids.add(identifier)
            added_counts[subject] += 1
            count += 1
            index += 1

    questions.extend(new_entries)

    if len(questions) < TARGET_TOTAL:
        raise RuntimeError(f"Nombre insuffisant de questions ({len(questions)}) pour atteindre {TARGET_TOTAL}")

    dump_questions(INPUT_PATH, questions)

    print("Questions initiales :", len(questions) - sum(added_counts.values()))
    print("Questions ajoutées :", dict(added_counts))
    print("Total final :", len(questions))


if __name__ == "__main__":
    main()
