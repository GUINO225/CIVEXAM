import json
from json import JSONDecoder
from itertools import count
from pathlib import Path

DATA_FILE = Path('assets/questions/civexam_questions_ena_core.json')


def parse_existing(path: Path):
    decoder = JSONDecoder()
    text = path.read_text(encoding='utf-8')
    questions = []
    idx = 0
    while True:
        start = text.find('{', idx)
        if start == -1:
            break
        try:
            obj, end = decoder.raw_decode(text, start)
        except json.JSONDecodeError:
            idx = start + 1
            continue
        questions.append(obj)
        idx = end
    return questions

IP_ENTRIES = [
    ("Souveraineté nationale", "la souveraineté appartient au peuple qui l'exerce par ses représentants élus"),
    ("État de droit", "les autorités publiques comme les citoyens sont soumis à la Constitution et aux lois"),
    ("Séparation des pouvoirs", "les fonctions législative, exécutive et judiciaire sont réparties pour limiter l'arbitraire"),
    ("Primauté de la Constitution", "toute norme inférieure doit être conforme au texte constitutionnel"),
    ("Suprématie des traités ratifiés", "les engagements internationaux régulièrement ratifiés priment sur les lois ordinaires"),
    ("Principe de légalité", "l'action administrative doit toujours trouver son fondement dans la loi"),
    ("Continuité de l'État", "les institutions doivent fonctionner sans interruption même en période de crise"),
    ("Responsabilité de l'administration", "les citoyens peuvent obtenir réparation des dommages causés par les services publics"),
    ("Neutralité de l'État", "le pouvoir public ne privilégie aucune conviction religieuse ou philosophique"),
    ("Principe d'égalité", "tous les citoyens sont soumis aux mêmes droits et obligations sans discrimination"),
    ("Participation citoyenne", "les citoyens interviennent dans la vie publique par le vote et la consultation"),
    ("Principe de subsidiarité", "la décision doit être prise par le niveau d'autorité le plus proche du citoyen"),
    ("Principe de solidarité", "la collectivité organise la mutualisation des risques et des charges"),
    ("Principe de laïcité", "l'État garantit la liberté de conscience en restant séparé des organisations religieuses"),
    ("Principe de transparence", "les autorités doivent rendre compte de leur action et communiquer l'information publique"),
    ("Principe de mutabilité", "le service public peut évoluer pour s'adapter aux besoins de la société"),
    ("Principe de continuité territoriale", "le service public doit être accessible sur l'ensemble du territoire"),
    ("Principe de participation", "les acteurs concernés sont associés à l'élaboration des décisions publiques"),
    ("Principe de sécurité juridique", "les règles doivent être stables, accessibles et prévisibles pour les citoyens"),
    ("Principe de précaution", "l'absence de certitude scientifique ne doit pas retarder l'adoption de mesures de protection"),
    ("Principe de proportionnalité", "les mesures de police doivent être adaptées, nécessaires et équilibrées"),
    ("Principe de spécialité", "un établissement public n'agit que dans le cadre des compétences qui lui sont attribuées"),
    ("Principe de hiérarchie des normes", "chaque règle tire sa validité d'une norme supérieure jusqu'à la Constitution"),
    ("Principe de collégialité", "plusieurs membres délibèrent ensemble afin de prendre une décision"),
    ("Principe de stabilité gouvernementale", "les institutions organisent une durée fixe des mandats exécutifs pour éviter l'instabilité"),
]

OP_ENTRIES = [
    ("Président de la République", "nomme le Premier ministre et veille au respect de la Constitution"),
    ("Premier ministre", "dirige l'action du gouvernement et assure l'exécution des lois"),
    ("Conseil des ministres", "délibère sur les politiques publiques et arrête les projets de loi"),
    ("Assemblée nationale", "vote la loi et contrôle l'action du gouvernement"),
    ("Sénat", "assure une représentation des collectivités territoriales dans le processus législatif"),
    ("Conseil constitutionnel", "veille à la conformité des lois et arbitre les élections nationales"),
    ("Cour des comptes", "contrôle la régularité des finances publiques et évalue les politiques"),
    ("Conseil d'État", "conseille le gouvernement et juge en dernier ressort le contentieux administratif"),
    ("Haute autorité de l'audiovisuel", "garantit le pluralisme des médias et régule la communication audiovisuelle"),
    ("Grand chancelier des ordres nationaux", "gère les distinctions honorifiques de l'État"),
    ("Conseil économique, social et environnemental", "donne des avis consultatifs sur les politiques publiques"),
    ("Gouverneur de district", "représente l'État dans la collectivité territoriale et coordonne les services déconcentrés"),
    ("Préfet", "assure le contrôle de légalité des actes des collectivités locales"),
    ("Maire", "dirige l'exécutif communal et met en œuvre les délibérations du conseil municipal"),
    ("Conseil municipal", "règle par délibération les affaires de la commune"),
    ("Commission électorale indépendante", "organise les scrutins et proclame les résultats provisoires"),
    ("Garde des Sceaux", "dirige la politique pénale et veille au fonctionnement du service public de la justice"),
    ("Ministre de l'Intérieur", "assure la sécurité intérieure et la gestion de l'administration territoriale"),
    ("Autorité nationale de la concurrence", "veille au respect des règles de libre concurrence"),
    ("Conseil national de sécurité", "coordonne la stratégie nationale de défense"),
    ("Chef d'état-major des armées", "commande les forces armées et assure leur préparation"),
    ("Haute cour de justice", "juge le président de la République et les membres du gouvernement pour haute trahison"),
    ("Conseil supérieur de la magistrature", "gère la carrière des magistrats et garantit leur indépendance"),
    ("Commission nationale des droits de l'homme", "surveille le respect des droits fondamentaux par les institutions"),
    ("Autorité de régulation des marchés publics", "veille à la transparence et à l'équité des procédures d'achat public"),
]

DL_ENTRIES = [
    ("Liberté d'expression", "chacun peut exprimer ses opinions dans le respect de la loi"),
    ("Liberté de conscience", "nul ne peut être inquiété pour ses convictions religieuses ou philosophiques"),
    ("Liberté de réunion", "les citoyens peuvent se rassembler pacifiquement sans autorisation préalable"),
    ("Liberté d'association", "toute personne peut créer une organisation sans ingérence injustifiée"),
    ("Liberté de la presse", "les journalistes peuvent informer sans censure préalable"),
    ("Liberté d'aller et venir", "chacun peut circuler librement sur le territoire national"),
    ("Droit de vote", "les citoyens participent à la désignation de leurs représentants"),
    ("Droit de pétition", "les citoyens peuvent saisir les autorités pour exposer leurs doléances"),
    ("Droit de grève", "les travailleurs peuvent cesser le travail pour défendre leurs intérêts professionnels"),
    ("Droit à l'éducation", "l'État garantit l'accès à une instruction publique"),
    ("Droit à la santé", "tout individu doit pouvoir bénéficier d'une prise en charge sanitaire"),
    ("Droit au logement", "chacun a vocation à disposer d'un habitat décent"),
    ("Droit au travail", "l'État favorise l'accès à un emploi pour tous"),
    ("Droit à la participation", "les populations locales sont associées à la gestion des affaires publiques"),
    ("Droit à l'information", "les citoyens ont accès aux documents administratifs"),
    ("Protection de la vie privée", "toute personne doit voir ses données personnelles respectées"),
    ("Présomption d'innocence", "un individu est considéré innocent tant que sa culpabilité n'a pas été établie"),
    ("Droit à un procès équitable", "chacun doit être jugé par un tribunal impartial dans un délai raisonnable"),
    ("Interdiction de la torture", "nul ne peut être soumis à des traitements cruels ou inhumains"),
    ("Protection des minorités", "les groupes vulnérables bénéficient de mesures spécifiques"),
    ("Égalité devant la justice", "toute personne peut faire valoir ses droits devant les tribunaux"),
    ("Liberté syndicale", "les travailleurs peuvent créer et rejoindre un syndicat"),
    ("Droit d'asile", "toute personne persécutée peut demander protection"),
    ("Droit à la nationalité", "chacun a droit à une appartenance légale à une communauté politique"),
    ("Droit à un environnement sain", "les autorités doivent prévenir les atteintes graves à la nature"),
]

JC_ENTRIES = [
    ("Contrôle de constitutionnalité a priori", "le Conseil constitutionnel vérifie une loi avant sa promulgation"),
    ("Contrôle de constitutionnalité a posteriori", "une loi peut être contestée après son entrée en vigueur"),
    ("Question prioritaire de constitutionnalité", "tout justiciable peut contester la conformité d'une loi à la Constitution"),
    ("Saisine parlementaire", "un groupe de députés ou de sénateurs peut demander l'examen d'une loi"),
    ("Saisine présidentielle", "le chef de l'État peut transmettre une loi au Conseil constitutionnel"),
    ("Bloc de constitutionnalité", "l'ensemble des textes et principes de référence pour le juge constitutionnel"),
    ("Effet abrogatif", "une disposition déclarée inconstitutionnelle disparaît de l'ordre juridique"),
    ("Effet différé", "le Conseil constitutionnel peut reporter la date d'abrogation d'une norme"),
    ("Incompatibilité manifeste", "le juge constitutionnel écarte une loi lorsque son opposition au texte suprême est évidente"),
    ("Conformité sous réserve", "le Conseil admet une loi à condition qu'elle soit interprétée d'une certaine manière"),
    ("Non-conformité totale", "le Conseil censure l'ensemble d'une loi"),
    ("Non-conformité partielle", "seules certaines dispositions de la loi sont censurées"),
    ("Décision interprétative", "le Conseil précise le sens d'une disposition pour la rendre conforme"),
    ("Décision additive", "le Conseil complète la loi en y ajoutant une interprétation obligatoire"),
    ("Recours direct des candidats", "les candidats aux élections peuvent contester la régularité du scrutin"),
    ("Contrôle des engagements internationaux", "le juge constitutionnel vérifie la conformité d'un traité avant ratification"),
    ("Compétence consultative", "le Conseil donne un avis sur l'organisation des pouvoirs publics"),
    ("Serment des membres", "les juges constitutionnels prêtent serment de remplir leurs fonctions en toute impartialité"),
    ("Inamovibilité", "les membres du Conseil constitutionnel ne peuvent être révoqués avant la fin de leur mandat"),
    ("Incompatibilités", "certaines fonctions politiques ou administratives sont interdites aux membres du Conseil"),
    ("Composition par tiers", "le Conseil est renouvelé partiellement tous les trois ans"),
    ("Mandat non renouvelable", "un membre ne peut être reconduit immédiatement après son mandat"),
    ("Secret du délibéré", "les discussions internes du Conseil ne sont pas rendues publiques"),
    ("Publication des décisions", "les décisions sont notifiées au président de la République et publiées au journal officiel"),
    ("Autorité absolue de la chose jugée", "les décisions du Conseil s'imposent à tous les pouvoirs publics"),
]


def build_dual(entries, subject, chapter, code, start, template_question, template_definition):
    questions = []
    counter = count(start)
    names = [name for name, _ in entries]
    definitions = [definition for _, definition in entries]
    size = len(entries)
    for idx, (name, definition) in enumerate(entries):
        number = next(counter)
        questions.append(
            {
                "id": f"DC-{code}-{number:04d}",
                "concours": "ENA",
                "subject": subject,
                "chapter": chapter,
                "difficulty": 1 if idx < size // 2 else 2,
                "question": template_question.format(definition=definition, name=name),
                "choices": [name] + [names[(idx + offset) % size] for offset in range(1, 4)],
                "answerIndex": 0,
                "explanation": f"Le principe de {name} se définit ainsi : {definition}.",
            }
        )
        number = next(counter)
        questions.append(
            {
                "id": f"DC-{code}-{number:04d}",
                "concours": "ENA",
                "subject": subject,
                "chapter": chapter,
                "difficulty": 2 if idx < size // 2 else 3,
                "question": template_definition.format(definition=definition, name=name),
                "choices": [definition] + [definitions[(idx + offset) % size] for offset in range(1, 4)],
                "answerIndex": 0,
                "explanation": f"Cela correspond au principe de {name}.",
            }
        )
    return questions


def generate_droit_constitutionnel():
    questions = []
    questions += build_dual(IP_ENTRIES, "Droit Constitutionnel", "Institutions & principes", "IP", 3001,
                            "Quel principe constitutionnel affirme que {definition} ?",
                            "Que signifie le principe de {name} ?")
    questions += build_dual(OP_ENTRIES, "Droit Constitutionnel", "Organisation des pouvoirs", "OP", 3201,
                            "Quel acteur institutionnel {definition} ?",
                            "Quelle mission revient à {name} ?")
    questions += build_dual(DL_ENTRIES, "Droit Constitutionnel", "Droits & libertés", "DL", 3401,
                            "Quel droit fondamental garantit que {definition} ?",
                            "Que protège le droit suivant : {name} ?")
    questions += build_dual(JC_ENTRIES, "Droit Constitutionnel", "Justice constitutionnelle", "JC", 3601,
                            "Quelle notion de justice constitutionnelle signifie que {definition} ?",
                            "Que décrit l'expression {name} ?")
    return questions

MA_ENTRIES = [
    ("Produit intérieur brut", "mesure la valeur totale des biens et services produits sur un territoire durant une période donnée"),
    ("Croissance économique", "reflète l'augmentation soutenue du niveau de production d'un pays"),
    ("Inflation", "correspond à la hausse générale et durable des prix à la consommation"),
    ("Déflation", "désigne la baisse durable du niveau général des prix"),
    ("Stagflation", "associe stagnation de l'activité économique et forte inflation"),
    ("Balance des paiements", "enregistre l'ensemble des flux monétaires entre un pays et le reste du monde"),
    ("Balance commerciale", "mesure la différence entre les exportations et les importations de biens"),
    ("Taux de chômage", "indique la part de la population active sans emploi mais en recherche"),
    ("Taux d'intérêt directeur", "prix auquel la banque centrale prête aux banques commerciales"),
    ("Déficit budgétaire", "apparaît lorsque les dépenses publiques excèdent les recettes"),
    ("Dette publique", "représente l'ensemble des emprunts contractés par l'État et les administrations publiques"),
    ("Politique budgétaire", "utilise la variation des recettes et dépenses publiques pour stabiliser l'économie"),
    ("Politique monétaire", "agit sur la quantité de monnaie et les taux d'intérêt pour atteindre des objectifs économiques"),
    ("Taux de change", "exprime la valeur d'une monnaie nationale par rapport à une autre"),
    ("Récession", "caractérise une contraction de l'activité pendant au moins deux trimestres consécutifs"),
    ("Cycle économique", "alterne des phases d'expansion et de ralentissement de l'activité"),
    ("Output gap", "mesure l'écart entre la production effective et la production potentielle"),
    ("Investissement public", "correspond aux dépenses de l'État destinées à accroître le capital collectif"),
    ("Produit national brut", "évalue la production réalisée par les résidents d'un pays quel que soit le lieu"),
    ("Terme de l'échange", "compare l'évolution des prix des exportations et des importations"),
    ("Politique de relance", "vise à stimuler l'activité économique par des dépenses supplémentaires"),
    ("Austérité", "cherche à réduire les déficits publics via des coupes budgétaires et hausses d'impôts"),
    ("Monétisation de la dette", "consiste à financer les déficits par la création monétaire"),
    ("Croissance inclusive", "s'assure que l'expansion économique bénéficie à l'ensemble de la population"),
    ("Transition énergétique", "désigne la mutation du système de production vers des sources d'énergie durables"),
]

MI_ENTRIES = [
    ("Offre", "quantité d'un bien que les producteurs souhaitent vendre à un prix donné"),
    ("Demande", "quantité d'un bien que les consommateurs désirent acheter à un prix donné"),
    ("Élasticité-prix de la demande", "mesure la sensibilité de la demande aux variations de prix"),
    ("Coût marginal", "coût supplémentaire engendré par la production d'une unité additionnelle"),
    ("Recette marginale", "gain supplémentaire procuré par la vente d'une unité additionnelle"),
    ("Profit", "différence entre les recettes totales et les coûts totaux"),
    ("Marché concurrentiel", "ensemble où de nombreux offreurs et demandeurs ne peuvent influencer individuellement les prix"),
    ("Monopole", "situation où un seul producteur fournit l'ensemble du marché"),
    ("Oligopole", "marché dominé par un petit nombre d'entreprises"),
    ("Concurrence monopolistique", "marché où de nombreux producteurs proposent des biens différenciés"),
    ("Externalité", "effet positif ou négatif de l'activité d'un agent sur un autre sans compensation monétaire"),
    ("Bien public", "bien non rival et non excluable disponible pour tous"),
    ("Bien collectif", "bien dont la consommation par un individu n'empêche pas celle des autres"),
    ("Sélection adverse", "situation où l'information imparfaite détériore la qualité moyenne d'un marché"),
    ("Aléa moral", "modification du comportement d'un agent une fois couvert par un contrat"),
    ("Prix d'équilibre", "prix auquel la quantité offerte égale la quantité demandée"),
    ("Surplus du consommateur", "gain ressenti par un acheteur lorsque le prix payé est inférieur à ce qu'il était prêt à offrir"),
    ("Surplus du producteur", "gain obtenu par un vendeur lorsque le prix reçu dépasse son coût minimal"),
    ("Coût fixe", "dépense qui ne varie pas avec le volume de production"),
    ("Coût variable", "dépense qui dépend directement du niveau de production"),
    ("Discrimination par les prix", "pratique consistant à facturer un même bien à des prix différents selon les clients"),
    ("Théorie des jeux", "analyse des décisions stratégiques entre agents interdépendants"),
    ("Stratégie dominante", "choix qui procure un gain supérieur quelle que soit la décision de l'adversaire"),
    ("Information imparfaite", "situation où tous les agents ne disposent pas des mêmes connaissances"),
    ("Asymétrie d'information", "distribution inégale de l'information entre les acteurs du marché"),
]

PP_ENTRIES = [
    ("Politique industrielle", "soutient la modernisation et la compétitivité des secteurs productifs"),
    ("Politique agricole", "oriente les productions rurales et assure la sécurité alimentaire"),
    ("Politique de l'emploi", "met en œuvre des dispositifs pour favoriser les embauches et la formation"),
    ("Protection sociale", "regroupe les mécanismes de couverture des risques de la vie"),
    ("Transferts sociaux", "redistribuent des revenus via les allocations et subventions"),
    ("Politique fiscale", "définit les impôts et taxes pour financer l'action publique"),
    ("Décentralisation", "transfère des compétences de l'État vers les collectivités territoriales"),
    ("Aménagement du territoire", "organise la répartition des activités et des infrastructures"),
    ("Politique énergétique", "structure le mix énergétique et encourage les économies d'énergie"),
    ("Politique éducative", "vise l'amélioration de l'accès et de la qualité du système scolaire"),
    ("Politique de santé", "assure la prévention et le traitement des maladies au niveau national"),
    ("Politique de logement", "favorise la construction et la réhabilitation d'habitations"),
    ("Politiques de jeunesse", "accompagnent l'insertion sociale et professionnelle des jeunes"),
    ("Politiques de genre", "luttent contre les discriminations entre femmes et hommes"),
    ("Politiques migratoires", "encadrent l'entrée et le séjour des étrangers"),
    ("Politique de sécurité", "met en place des mesures pour protéger les personnes et les biens"),
    ("Politique de transport", "développe les réseaux routiers, ferroviaires, maritimes et aériens"),
    ("Politique de recherche", "finance l'innovation scientifique et technologique"),
    ("Politique culturelle", "soutient la création artistique et la diffusion du patrimoine"),
    ("Politique de la ville", "agit sur le développement des quartiers en difficulté"),
    ("Gouvernance électronique", "utilise le numérique pour améliorer les services publics"),
    ("Dialogue social", "organise les relations entre employeurs, salariés et autorités publiques"),
    ("Cadre réglementaire", "fixe des normes et procédures pour encadrer l'activité économique"),
    ("Partenariat public-privé", "associe l'État et des entreprises pour réaliser des investissements"),
    ("Évaluation des politiques", "mesure l'efficacité et l'impact des programmes publics"),
]

DS_ENTRIES = [
    ("Indice de développement humain", "combine le revenu par habitant, l'espérance de vie et le niveau d'éducation"),
    ("Indice de pauvreté multidimensionnelle", "apprécie les privations en matière de santé, d'éducation et de conditions de vie"),
    ("Transition démographique", "décrit le passage d'un régime de forte natalité et mortalité à un régime de faibles taux"),
    ("Dividende démographique", "potentiel de croissance lié à l'augmentation de la population active"),
    ("Taux d'alphabétisation", "mesure la proportion de personnes sachant lire et écrire"),
    ("Inégalités de revenus", "évaluent la distribution de la richesse entre les individus"),
    ("Coefficient de Gini", "quantifie le niveau d'inégalités de revenus sur une échelle de 0 à 1"),
    ("Croissance démographique", "indique l'évolution du nombre d'habitants d'une population"),
    ("Urbanisation", "désigne l'augmentation de la population vivant en ville"),
    ("Exode rural", "décrit le mouvement de populations quittant les campagnes pour s'installer en ville"),
    ("Sécurité alimentaire", "assure un accès physique et économique à une nourriture suffisante"),
    ("Économie informelle", "regroupe les activités productives non déclarées"),
    ("Insertion professionnelle", "processus par lequel un individu trouve et conserve un emploi"),
    ("Protection de l'environnement", "vise la préservation des ressources naturelles"),
    ("Responsabilité sociale des entreprises", "intègre les préoccupations sociales et environnementales dans la stratégie"),
    ("Inclusion financière", "assure l'accès des populations aux services bancaires et de crédit"),
    ("Égalité de genre", "vise l'équilibre des droits et des opportunités entre femmes et hommes"),
    ("Sécurité sociale", "met en place des filets de protection contre les risques de la vie"),
    ("Capital humain", "ensemble des connaissances, compétences et santé d'une population"),
    ("Migration interne", "déplacements de populations au sein d'un même pays"),
    ("Développement durable", "concilie progrès économique, justice sociale et protection de l'environnement"),
    ("Participation citoyenne", "associe les habitants aux décisions affectant leur communauté"),
    ("Filets sociaux", "programmes publics qui protègent les ménages vulnérables"),
    ("Économie sociale et solidaire", "activités économiques fondées sur la coopération et la gouvernance démocratique"),
    ("Accès à l'eau potable", "garantit une ressource sûre et disponible pour la population"),
]


def generate_problemes_economiques():
    questions = []
    questions += build_dual(MA_ENTRIES, "Problèmes Économiques & Sociaux", "Macroéconomie", "MA", 4001,
                            "Quel indicateur macroéconomique {definition} ?",
                            "Que mesure {name} ?")
    questions += build_dual(MI_ENTRIES, "Problèmes Économiques & Sociaux", "Microéconomie", "MI", 4201,
                            "Quelle notion de microéconomie correspond à {definition} ?",
                            "Comment définit-on {name} ?")
    questions += build_dual(PP_ENTRIES, "Problèmes Économiques & Sociaux", "Politiques publiques", "PP", 4401,
                            "Quelle politique publique {definition} ?",
                            "Quel est l'objectif principal de {name} ?")
    questions += build_dual(DS_ENTRIES, "Problèmes Économiques & Sociaux", "Développement & société", "DS", 4601,
                            "Quel concept de développement {definition} ?",
                            "Que décrit l'indicateur {name} ?")
    return questions

def make_calcul_mental(start_id=5001):
    questions = []
    counter = count(start_id)
    for idx in range(50):
        a = 18 + idx
        b = 7 + (idx % 9)
        c = 3 + (idx % 5)
        if idx % 3 == 0:
            question = f"Calculez : {a} + {b} × {c}."
            correct = a + b * c
            explanation = f"On effectue d'abord la multiplication {b} × {c} = {b * c}, puis on ajoute {a} pour obtenir {correct}."
        elif idx % 3 == 1:
            question = f"Quelle est la valeur de ({a} − {b}) × {c} ?"
            correct = (a - b) * c
            explanation = f"On calcule {a} − {b} = {a - b}, puis on multiplie par {c} pour obtenir {correct}."
        else:
            question = f"Résolvez : {a} × {c} − {b}."
            correct = a * c - b
            explanation = f"{a} × {c} = {a * c}, puis on retranche {b} pour obtenir {correct}."
        distractors = [correct + 5, correct - 4, correct + 9]
        questions.append(
            {
                "id": f"AN-CM-{next(counter):04d}",
                "concours": "ENA",
                "subject": "Aptitude Numérique",
                "chapter": "Calcul mental",
                "difficulty": 1 if idx < 25 else 2,
                "question": question,
                "choices": [correct] + distractors,
                "answerIndex": 0,
                "explanation": explanation,
            }
        )
    return questions


def make_pourcentages(start_id=5201):
    questions = []
    counter = count(start_id)
    bases = [120, 150, 180, 200, 250, 300, 360, 420, 480, 550]
    rates = [5, 8, 10, 12, 15, 18, 20, 22, 25, 30]
    for idx in range(50):
        base = bases[idx % len(bases)] + 10 * (idx // len(bases))
        rate = rates[idx % len(rates)]
        if idx % 2 == 0:
            new_value = base * (100 + rate) / 100
            question = f"Un montant de {base} FCFA augmente de {rate} %. Quel est le nouveau montant ?"
            explanation = f"On ajoute {rate} % à {base} : {base} × (1 + {rate}/100) = {new_value:.2f}."
        else:
            new_value = base * (100 - rate) / 100
            question = f"Une remise de {rate} % est appliquée sur {base} FCFA. Quel est le prix après réduction ?"
            explanation = f"On retire {rate} % de {base} : {base} × (1 − {rate}/100) = {new_value:.2f}."
        correct = round(new_value, 2)
        distractors = [round(correct + rate, 2), round(correct - rate / 2, 2), round(correct + base * 0.05, 2)]
        questions.append(
            {
                "id": f"AN-PR-{next(counter):04d}",
                "concours": "ENA",
                "subject": "Aptitude Numérique",
                "chapter": "Pourcentages & ratios",
                "difficulty": 1 if idx < 25 else 2,
                "question": question,
                "choices": [correct] + distractors,
                "answerIndex": 0,
                "explanation": explanation,
            }
        )
    return questions


def make_suites(start_id=5401):
    questions = []
    counter = count(start_id)
    for idx in range(50):
        if idx % 4 == 0:
            start = 3 + idx
            step = 2 + (idx % 5)
            seq = [start + step * n for n in range(4)]
            correct = start + step * 4
            question = f"Quelle est la valeur suivante de la suite {seq[0]}, {seq[1]}, {seq[2]}, {seq[3]}, ... ?"
            explanation = f"La suite augmente de {step} à chaque terme; le prochain vaut {correct}."
        elif idx % 4 == 1:
            start = 2 + (idx % 6)
            ratio = 2
            seq = [start * (ratio ** n) for n in range(4)]
            correct = seq[-1] * ratio
            question = f"Quel nombre complète la suite géométrique {seq[0]}, {seq[1]}, {seq[2]}, {seq[3]}, ... ?"
            explanation = f"Chaque terme est multiplié par {ratio}; on obtient {correct}."
        elif idx % 4 == 2:
            seq = [1, 1]
            for _ in range(2):
                seq.append(seq[-1] + seq[-2])
            shift = idx // 4
            seq = [x + shift for x in seq]
            correct = seq[-1] + seq[-2]
            question = f"Quel est le terme suivant de la suite {seq[0]}, {seq[1]}, {seq[2]}, {seq[3]}, ... ?"
            explanation = f"Chaque terme est la somme des deux précédents; le suivant vaut {correct}."
        else:
            base = 5 + (idx % 7)
            seq = [base * n for n in range(1, 5)]
            correct = base * 5
            question = f"Quelle valeur complète la progression {seq[0]}, {seq[1]}, {seq[2]}, {seq[3]}, ... ?"
            explanation = f"Il s'agit des multiples de {base}; le prochain est {correct}."
        distractors = [correct + 3, correct - 2, correct + 6]
        questions.append(
            {
                "id": f"AN-SS-{next(counter):04d}",
                "concours": "ENA",
                "subject": "Aptitude Numérique",
                "chapter": "Suites & séries",
                "difficulty": 2 if idx < 25 else 3,
                "question": question,
                "choices": [correct] + distractors,
                "answerIndex": 0,
                "explanation": explanation,
            }
        )
    return questions


def make_problemes(start_id=5601):
    questions = []
    counter = count(start_id)
    for idx in range(50):
        if idx % 3 == 0:
            distance = 120 + 10 * idx
            speed = 40 + (idx % 5) * 5
            time = distance / speed
            question = f"Un véhicule parcourt {distance} km à {speed} km/h. Combien d'heures dure le trajet ?"
            explanation = f"On divise la distance par la vitesse : {distance} / {speed} = {time:.2f} heures."
            correct = round(time, 2)
        elif idx % 3 == 1:
            workers = 4 + (idx % 6)
            days = 15 + (idx % 7)
            production = workers * days * 12
            question = f"{workers} ouvriers produisent chacun 12 pièces par jour pendant {days} jours. Combien de pièces fabriquent-ils ?"
            explanation = f"On multiplie {workers} × {days} × 12 = {production}."
            correct = production
        else:
            tank = 800 + 20 * idx
            flow = 40 + (idx % 4) * 10
            time = tank / flow
            question = f"Un réservoir de {tank} litres est rempli par un débit de {flow} litres par minute. Combien de minutes sont nécessaires ?"
            explanation = f"On calcule {tank} / {flow} = {time:.2f} minutes."
            correct = round(time, 2)
        distractors = [round(correct + 5, 2), round(correct - 3, 2), round(correct + 10, 2)]
        questions.append(
            {
                "id": f"AN-PP-{next(counter):04d}",
                "concours": "ENA",
                "subject": "Aptitude Numérique",
                "chapter": "Problèmes pratiques",
                "difficulty": 2 if idx < 25 else 3,
                "question": question,
                "choices": [correct] + distractors,
                "answerIndex": 0,
                "explanation": explanation,
            }
        )
    return questions


def generate_aptitude_numerique():
    questions = []
    questions += make_calcul_mental()
    questions += make_pourcentages()
    questions += make_suites()
    questions += make_problemes()
    return questions


def make_synonymes(start_id=6001):
    questions = []
    counter = count(start_id)
    size = len(SYN_ENTRIES)
    for idx, entry in enumerate(SYN_ENTRIES):
        syn_number = next(counter)
        questions.append(
            {
                "id": f"AV-SY-{syn_number:04d}",
                "concours": "ENA",
                "subject": "Aptitude Verbale",
                "chapter": "Synonymes & antonymes",
                "difficulty": 1 if idx < size // 2 else 2,
                "question": (
                    f"Quel est le synonyme le plus proche du mot « {entry['word']} » ?"
                ),
                "choices": [entry["synonym"]] + entry["syn_distractors"],
                "answerIndex": 0,
                "explanation": (
                    f"Le terme qui conserve le sens de « {entry['word']} » est « {entry['synonym']} »."
                ),
            }
        )
        ant_number = next(counter)
        questions.append(
            {
                "id": f"AV-SY-{ant_number:04d}",
                "concours": "ENA",
                "subject": "Aptitude Verbale",
                "chapter": "Synonymes & antonymes",
                "difficulty": 2 if idx < size // 2 else 3,
                "question": (
                    f"Quel mot est le plus opposé au sens de « {entry['word']} » ?"
                ),
                "choices": [entry["antonym"]] + entry["ant_distractors"],
                "answerIndex": 0,
                "explanation": (
                    f"Le contraire de « {entry['word']} » est « {entry['antonym']} »."
                ),
            }
        )
    return questions


def make_comprehension(start_id=6201):
    questions = []
    counter = count(start_id)
    size = len(COMP_ENTRIES)
    for idx, entry in enumerate(COMP_ENTRIES):
        main_number = next(counter)
        questions.append(
            {
                "id": f"AV-CO-{main_number:04d}",
                "concours": "ENA",
                "subject": "Aptitude Verbale",
                "chapter": "Compréhension de texte",
                "difficulty": 1 if idx < size // 2 else 2,
                "question": (
                    "Quel est l'objectif principal du texte suivant ?\n\n"
                    f"{entry['text']}"
                ),
                "choices": [entry["main_answer"]] + entry["main_distractors"],
                "answerIndex": 0,
                "explanation": (
                    f"Le texte indique clairement : {entry['main_answer']}."
                ),
            }
        )
        detail_number = next(counter)
        questions.append(
            {
                "id": f"AV-CO-{detail_number:04d}",
                "concours": "ENA",
                "subject": "Aptitude Verbale",
                "chapter": "Compréhension de texte",
                "difficulty": 2 if idx < size // 2 else 3,
                "question": (
                    f"{entry['detail_question']}\n\nTexte : {entry['text']}"
                ),
                "choices": [entry["detail_answer"]] + entry["detail_distractors"],
                "answerIndex": 0,
                "explanation": (
                    f"Le passage précise : {entry['detail_answer']}."
                ),
            }
        )
    return questions


def make_orthographe(start_id=6401):
    questions = []
    counter = count(start_id)
    size = len(ORTHO_ENTRIES)
    for idx, entry in enumerate(ORTHO_ENTRIES):
        fill_number = next(counter)
        questions.append(
            {
                "id": f"AV-OR-{fill_number:04d}",
                "concours": "ENA",
                "subject": "Aptitude Verbale",
                "chapter": "Orthographe & grammaire",
                "difficulty": 1 if idx < size // 2 else 2,
                "question": (
                    "Complétez la phrase : "
                    f"{entry['sentence']}"
                ),
                "choices": entry["choices_fill"],
                "answerIndex": entry["fill_index"],
                "explanation": entry["explanation_fill"],
            }
        )
        detail_number = next(counter)
        questions.append(
            {
                "id": f"AV-OR-{detail_number:04d}",
                "concours": "ENA",
                "subject": "Aptitude Verbale",
                "chapter": "Orthographe & grammaire",
                "difficulty": 2 if idx < size // 2 else 3,
                "question": entry["detail_question"],
                "choices": entry["detail_choices"],
                "answerIndex": entry["detail_index"],
                "explanation": entry["explanation_detail"],
            }
        )
    return questions


def make_expression(start_id=6601):
    questions = []
    counter = count(start_id)
    size = len(EXPR_ENTRIES)
    for idx, entry in enumerate(EXPR_ENTRIES):
        connector_number = next(counter)
        questions.append(
            {
                "id": f"AV-EX-{connector_number:04d}",
                "concours": "ENA",
                "subject": "Aptitude Verbale",
                "chapter": "Expression écrite",
                "difficulty": 1 if idx < size // 2 else 2,
                "question": (
                    "Choisissez le connecteur logique qui complète au mieux la phrase suivante :\n\n"
                    f"{entry['situation']}"
                ),
                "choices": entry["connector_choices"],
                "answerIndex": entry["connector_index"],
                "explanation": entry["connector_explanation"],
            }
        )
        rewrite_number = next(counter)
        questions.append(
            {
                "id": f"AV-EX-{rewrite_number:04d}",
                "concours": "ENA",
                "subject": "Aptitude Verbale",
                "chapter": "Expression écrite",
                "difficulty": 2 if idx < size // 2 else 3,
                "question": (
                    "Quelle reformulation respecte le sens de la phrase précédente ?"
                ),
                "choices": entry["rewrite_choices"],
                "answerIndex": entry["rewrite_index"],
                "explanation": entry["rewrite_explanation"],
            }
        )
    return questions


def generate_aptitude_verbale():
    questions = []
    questions += make_synonymes()
    questions += make_comprehension()
    questions += make_orthographe()
    questions += make_expression()
    return questions

SYN_ENTRIES = [
    {"word": "Abondant", "synonym": "copieux", "syn_distractors": ["rare", "maigre", "limité"], "antonym": "rare", "ant_distractors": ["généreux", "profus", "ample"]},
    {"word": "Brillant", "synonym": "lumineux", "syn_distractors": ["terne", "pâle", "opaque"], "antonym": "mat", "ant_distractors": ["clair", "vif", "radieux"]},
    {"word": "Calme", "synonym": "paisible", "syn_distractors": ["tumultueux", "orageux", "bruyant"], "antonym": "agité", "ant_distractors": ["posé", "doux", "placide"]},
    {"word": "Diligent", "synonym": "assidu", "syn_distractors": ["lent", "indolent", "mou"], "antonym": "négligent", "ant_distractors": ["soigneux", "appliqué", "rigoureux"]},
    {"word": "Éloquent", "synonym": "expressif", "syn_distractors": ["bref", "muet", "sec"], "antonym": "balbutiant", "ant_distractors": ["fluide", "persuasif", "clair"]},
    {"word": "Fervent", "synonym": "ardent", "syn_distractors": ["froid", "tiède", "indifférent"], "antonym": "tiède", "ant_distractors": ["passionné", "zélé", "ardent"]},
    {"word": "Généreux", "synonym": "altruiste", "syn_distractors": ["avare", "pingre", "chiche"], "antonym": "avare", "ant_distractors": ["prodigue", "libéral", "ouvert"]},
    {"word": "Habile", "synonym": "adroit", "syn_distractors": ["malhabile", "lourd", "gaucher"], "antonym": "maladroit", "ant_distractors": ["dextre", "agile", "habile"]},
    {"word": "Impartial", "synonym": "équitable", "syn_distractors": ["partiel", "injuste", "biaisé"], "antonym": "partisan", "ant_distractors": ["neutre", "objectif", "juste"]},
    {"word": "Joyeux", "synonym": "gai", "syn_distractors": ["morose", "sombre", "triste"], "antonym": "triste", "ant_distractors": ["enjoué", "joyeux", "festif"]},
    {"word": "Loyal", "synonym": "fidèle", "syn_distractors": ["fourbe", "perfide", "trompeur"], "antonym": "déloyal", "ant_distractors": ["sincère", "honnête", "dévoué"]},
    {"word": "Modeste", "synonym": "humble", "syn_distractors": ["prétentieux", "hautain", "fanfaron"], "antonym": "orgueilleux", "ant_distractors": ["discret", "simple", "retenu"]},
    {"word": "Nette", "synonym": "claire", "syn_distractors": ["trouble", "confuse", "brouillée"], "antonym": "floue", "ant_distractors": ["distincte", "précise", "limpide"]},
    {"word": "Obstiné", "synonym": "tenace", "syn_distractors": ["malléable", "docile", "souple"], "antonym": "conciliant", "ant_distractors": ["résolu", "ferme", "déterminé"]},
    {"word": "Prudent", "synonym": "circonspect", "syn_distractors": ["téméraire", "audacieux", "imprudent"], "antonym": "imprudent", "ant_distractors": ["sage", "avisé", "mesuré"]},
    {"word": "Raffiné", "synonym": "élégant", "syn_distractors": ["brut", "grossier", "simple"], "antonym": "grossier", "ant_distractors": ["distingué", "subtil", "soigné"]},
    {"word": "Sobre", "synonym": "mesuré", "syn_distractors": ["tapageur", "excessif", "voyant"], "antonym": "excessif", "ant_distractors": ["simple", "discret", "épuré"]},
    {"word": "Tolérant", "synonym": "indulgent", "syn_distractors": ["dur", "strict", "ferme"], "antonym": "intolérant", "ant_distractors": ["compréhensif", "souple", "accueillant"]},
    {"word": "Utile", "synonym": "bénéfique", "syn_distractors": ["vain", "nocif", "stérile"], "antonym": "inutile", "ant_distractors": ["rentable", "serviable", "pratique"]},
    {"word": "Vaillant", "synonym": "courageux", "syn_distractors": ["timoré", "craintif", "lâche"], "antonym": "lâche", "ant_distractors": ["brave", "hardi", "intrépide"]},
    {"word": "Vif", "synonym": "rapide", "syn_distractors": ["lent", "pesant", "mou"], "antonym": "lent", "ant_distractors": ["alerte", "dynamique", "prompt"]},
    {"word": "Zélé", "synonym": "dévoué", "syn_distractors": ["indifférent", "paresseux", "négligent"], "antonym": "indolent", "ant_distractors": ["ardent", "actif", "appliqué"]},
    {"word": "Assidu", "synonym": "studieux", "syn_distractors": ["absent", "épars", "négligent"], "antonym": "irrégulier", "ant_distractors": ["constant", "persévérant", "fidèle"]},
    {"word": "Brusque", "synonym": "abrupt", "syn_distractors": ["doux", "souple", "graduel"], "antonym": "doux", "ant_distractors": ["progressif", "mesuré", "modéré"]},
    {"word": "Captivant", "synonym": "fascinant", "syn_distractors": ["fade", "plat", "lassant"], "antonym": "ennuyeux", "ant_distractors": ["passionnant", "attrayant", "intéressant"]},
    {"word": "Docile", "synonym": "obéissant", "syn_distractors": ["récalcitrant", "rebelle", "insoumis"], "antonym": "rebelle", "ant_distractors": ["souple", "malléable", "accommodant"]},
]

COMP_ENTRIES = [
    {
        "text": "Le ministère de la Santé a lancé une campagne de vaccination mobile pour atteindre les villages isolés. Des équipes mixtes se déplacent chaque semaine afin d'administrer les doses et de sensibiliser les familles aux mesures de prévention.",
        "main_answer": "Étendre la vaccination dans les villages isolés",
        "main_distractors": ["Réorganiser les hôpitaux urbains", "Former de nouveaux médecins", "Distribuer des moustiquaires"],
        "detail_question": "Selon le texte, comment les équipes assurent-elles la prévention ?",
        "detail_answer": "Elles sensibilisent les familles aux mesures de prévention",
        "detail_distractors": ["Elles construisent de nouveaux dispensaires", "Elles livrent uniquement des médicaments", "Elles organisent des dépistages sanguins"],
    },
    {
        "text": "Pour dynamiser le commerce local, la mairie a transformé l'ancien marché couvert en centre artisanal. Les coopératives y exposent leurs produits et bénéficient d'ateliers de formation en marketing digital.",
        "main_answer": "Valoriser l'artisanat grâce à un nouveau centre",
        "main_distractors": ["Remplacer les commerces traditionnels par des supermarchés", "Construire une zone industrielle", "Installer une bibliothèque municipale"],
        "detail_question": "Quel service est offert aux coopératives ?",
        "detail_answer": "Des ateliers de formation en marketing digital",
        "detail_distractors": ["Des prêts à taux zéro", "Des cours de comptabilité en ligne", "Des études gratuites de marché"],
    },
    {
        "text": "L'université a revu son calendrier afin d'alterner les enseignements en présentiel et à distance. Ce dispositif permet de réduire l'affluence dans les amphithéâtres tout en maintenant la progression des programmes.",
        "main_answer": "Réduire l'affluence tout en poursuivant les cours",
        "main_distractors": ["Fermer les campus universitaires", "Augmenter la durée des vacances", "Supprimer les cours magistraux"],
        "detail_question": "Quel avantage offre cette nouvelle organisation ?",
        "detail_answer": "Elle maintient la progression des programmes",
        "detail_distractors": ["Elle permet de réduire le nombre d'examens", "Elle supprime les travaux dirigés", "Elle augmente les inscriptions"],
    },
    {
        "text": "La société de transport public expérimente une ligne nocturne reliant les quartiers périphériques au centre-ville. Les horaires ont été adaptés pour desservir les travailleurs de nuit et renforcer la sécurité des déplacements tardifs.",
        "main_answer": "Faciliter les déplacements nocturnes vers le centre-ville",
        "main_distractors": ["Supprimer les lignes diurnes", "Transporter uniquement les touristes", "Remplacer les bus par des taxis"],
        "detail_question": "Quelle mesure accompagne la ligne nocturne ?",
        "detail_answer": "Des horaires adaptés aux travailleurs de nuit",
        "detail_distractors": ["Des billets gratuits pour les étudiants", "Des bus à impériale", "Une navette vers l'aéroport"],
    },
    {
        "text": "Afin de préserver le littoral, une association organise des opérations régulières de nettoyage et de replantation de mangroves. Les bénévoles sont formés aux techniques de transplantation pour renforcer la barrière naturelle contre l'érosion.",
        "main_answer": "Protéger le littoral par le nettoyage et la replantation",
        "main_distractors": ["Aménager une zone portuaire", "Construire une digue en béton", "Développer des fermes aquacoles"],
        "detail_question": "Quelle compétence les bénévoles acquièrent-ils ?",
        "detail_answer": "Les techniques de transplantation de mangroves",
        "detail_distractors": ["La navigation de plaisance", "La surveillance maritime", "La culture des huîtres"],
    },
    {
        "text": "Le programme national de lecture a distribué des bibliothèques mobiles dans les écoles rurales. Chaque kit contient une centaine d'ouvrages adaptés à tous les niveaux et un guide pédagogique pour les enseignants.",
        "main_answer": "Favoriser la lecture dans les écoles rurales",
        "main_distractors": ["Créer des concours d'orthographe urbains", "Former exclusivement les bibliothécaires", "Financer des manuels universitaires"],
        "detail_question": "Que trouve-t-on dans chaque kit ?",
        "detail_answer": "Une centaine d'ouvrages et un guide pédagogique",
        "detail_distractors": ["Des tablettes numériques", "Une imprimante 3D", "Des cahiers d'écriture"],
    },
    {
        "text": "Pour réduire les embouteillages, la ville a mis en place un système de feux intelligents synchronisés. Les capteurs analysent le trafic en temps réel et ajustent la durée des feux selon la densité des véhicules.",
        "main_answer": "Fluidifier la circulation grâce à des feux intelligents",
        "main_distractors": ["Interdire l'accès au centre-ville", "Réserver la voirie aux bus", "Prolonger les travaux routiers"],
        "detail_question": "Sur quoi se basent les capteurs pour ajuster les feux ?",
        "detail_answer": "Sur la densité des véhicules observée en temps réel",
        "detail_distractors": ["Sur la météo", "Sur le prix du carburant", "Sur le nombre de parkings"],
    },
    {
        "text": "Une coopérative agricole a introduit des cultures maraîchères sous serre pour sécuriser ses revenus. Les producteurs récoltent désormais toute l'année et répondent aux commandes des cantines scolaires.",
        "main_answer": "Stabiliser les revenus grâce aux cultures sous serre",
        "main_distractors": ["Arrêter la production maraîchère", "Importer des légumes surgelés", "Vendre les terres agricoles"],
        "detail_question": "À quels clients la coopérative répond-elle ?",
        "detail_answer": "Aux cantines scolaires",
        "detail_distractors": ["Aux restaurants d'hôtel", "Aux marchés étrangers", "Aux grossistes en fruits"],
    },
    {
        "text": "Le service des forêts a développé une application mobile permettant aux citoyens de signaler les départs de feu. Chaque alerte est géolocalisée et transmise immédiatement aux brigades d'intervention.",
        "main_answer": "Impliquer les citoyens dans la détection des incendies",
        "main_distractors": ["Vendre du bois certifié en ligne", "Créer un jeu éducatif", "Recruter des pompiers volontaires"],
        "detail_question": "Que devient l'alerte après signalement ?",
        "detail_answer": "Elle est géolocalisée et transmise aux brigades",
        "detail_distractors": ["Elle reste visible uniquement pour l'utilisateur", "Elle est publiée sur les réseaux sociaux", "Elle est envoyée au ministère des Finances"],
    },
    {
        "text": "Une entreprise technologique a adopté la semaine de quatre jours pour favoriser l'équilibre vie professionnelle-vie privée. Les équipes se relayent pour assurer un service continu auprès des clients.",
        "main_answer": "Introduire la semaine de quatre jours",
        "main_distractors": ["Supprimer les congés annuels", "Externaliser l'ensemble des services", "Ouvrir de nouvelles filiales"],
        "detail_question": "Comment l'entreprise maintient-elle le service ?",
        "detail_answer": "Les équipes se relayent",
        "detail_distractors": ["Les bureaux restent fermés le vendredi", "Les clients se servent seuls", "Les contrats sont suspendus"],
    },
    {
        "text": "Un festival scientifique itinérant présente des expériences interactives dans les collèges. Les élèves manipulent des maquettes d'énergie renouvelable et discutent avec des chercheurs.",
        "main_answer": "Faire découvrir la science de manière ludique",
        "main_distractors": ["Organiser un concours sportif", "Remplacer les cours de mathématiques", "Installer un laboratoire permanent"],
        "detail_question": "Avec qui les élèves échangent-ils ?",
        "detail_answer": "Avec des chercheurs",
        "detail_distractors": ["Avec des élus locaux", "Avec des journalistes", "Avec des entrepreneurs"],
    },
    {
        "text": "La commune a mis en place un budget participatif destiné à financer des projets citoyens. Les habitants votent pour les initiatives qu'ils souhaitent voir réalisées dans leur quartier.",
        "main_answer": "Financer des projets choisis par les habitants",
        "main_distractors": ["Réduire la fiscalité locale", "Centraliser toutes les décisions", "Privatiser les services municipaux"],
        "detail_question": "Comment les projets sont-ils sélectionnés ?",
        "detail_answer": "Par le vote des habitants",
        "detail_distractors": ["Par tirage au sort", "Par décision préfectorale", "Par un conseil d'experts étrangers"],
    },
    {
        "text": "Pour soutenir les créateurs, une plateforme numérique met en relation artisans et clients internationaux. Les commandes sont expédiées grâce à un partenariat logistique avec une entreprise postale.",
        "main_answer": "Ouvrir un marché international aux artisans",
        "main_distractors": ["Standardiser la production artisanale", "Instaurer des droits de douane supplémentaires", "Limiter les exportations"],
        "detail_question": "Quel partenaire facilite les expéditions ?",
        "detail_answer": "Une entreprise postale",
        "detail_distractors": ["Une banque locale", "Un cabinet d'avocats", "Une agence immobilière"],
    },
    {
        "text": "La ville a installé des jardins partagés sur les toits de plusieurs bâtiments publics. Les riverains y cultivent légumes et plantes aromatiques en échange de quelques heures d'entretien par semaine.",
        "main_answer": "Créer des jardins partagés sur les toits",
        "main_distractors": ["Vendre les bâtiments publics", "Transformer les toits en parkings", "Installer des panneaux publicitaires"],
        "detail_question": "Quelle contrepartie est demandée aux riverains ?",
        "detail_answer": "Quelques heures d'entretien hebdomadaire",
        "detail_distractors": ["Un loyer mensuel", "La signature d'un bail commercial", "La participation à des réunions politiques"],
    },
    {
        "text": "Le centre hospitalier a ouvert une unité de télémédecine pour suivre les patients chroniques. Les consultations vidéo sont planifiées par les infirmiers qui recueillent également les constantes à distance.",
        "main_answer": "Assurer un suivi des patients chroniques à distance",
        "main_distractors": ["Remplacer les urgences", "Créer un service de chirurgie esthétique", "Organiser des campagnes de don du sang"],
        "detail_question": "Qui planifie les consultations vidéo ?",
        "detail_answer": "Les infirmiers",
        "detail_distractors": ["Les pharmaciens", "Les brancardiers", "Les chauffeurs"],
    },
    {
        "text": "Une bibliothèque municipale prête désormais des instruments de musique aux habitants. Avant l'emprunt, un musicien anime une séance d'initiation pour expliquer l'utilisation et l'entretien.",
        "main_answer": "Permettre l'emprunt d'instruments de musique",
        "main_distractors": ["Vendre des partitions rares", "Transformer la bibliothèque en salle de concert", "Numériser exclusivement des romans"],
        "detail_question": "Qui anime la séance d'initiation ?",
        "detail_answer": "Un musicien",
        "detail_distractors": ["Un bibliothécaire", "Un élu municipal", "Un professeur de sport"],
    },
    {
        "text": "Pour protéger les piétons, une grande avenue a été équipée de passages surélevés et de signalisations lumineuses. Les automobilistes sont ainsi contraints de ralentir à l'approche des écoles.",
        "main_answer": "Sécuriser les traversées piétonnes près des écoles",
        "main_distractors": ["Accélérer la circulation", "Supprimer les trottoirs", "Installer des stations-service"],
        "detail_question": "Qu'obligent les aménagements à faire ?",
        "detail_answer": "Ralentir les automobilistes",
        "detail_distractors": ["Stationner gratuitement", "Changer de voie", "Utiliser les transports en commun"],
    },
    {
        "text": "Une start-up agroalimentaire valorise les fruits invendus en les transformant en jus pasteurisés. Le procédé prolonge la durée de conservation tout en réduisant le gaspillage alimentaire.",
        "main_answer": "Réduire le gaspillage en transformant les invendus",
        "main_distractors": ["Importer des fruits exotiques", "Ouvrir des restaurants gastronomiques", "Créer une marque de vêtements"],
        "detail_question": "Quel procédé est utilisé ?",
        "detail_answer": "La pasteurisation des jus",
        "detail_distractors": ["La congélation rapide", "La lyophilisation", "La cuisson au four"],
    },
    {
        "text": "Le ministère de la Culture soutient des résidences d'artistes dans les zones rurales. Les créateurs animent des ateliers auprès des habitants avant de présenter leurs œuvres lors d'une exposition collective.",
        "main_answer": "Installer des résidences d'artistes en milieu rural",
        "main_distractors": ["Fermer les centres culturels", "Financer uniquement les grandes villes", "Remplacer les artistes par des artisans"],
        "detail_question": "Quelle activité précède l'exposition ?",
        "detail_answer": "Des ateliers animés par les créateurs",
        "detail_distractors": ["Une vente aux enchères", "Une projection de film", "Une conférence historique"],
    },
    {
        "text": "Le département des Sports propose un pass unique donnant accès à plusieurs disciplines pour les jeunes. Les clubs partenaires accueillent les nouveaux inscrits sans frais supplémentaires d'équipement.",
        "main_answer": "Offrir un pass multi-sports aux jeunes",
        "main_distractors": ["Limiter l'accès aux gymnases", "Sélectionner uniquement les athlètes professionnels", "Remplacer les clubs par des plateformes en ligne"],
        "detail_question": "Que prévoient les clubs partenaires ?",
        "detail_answer": "Aucun frais supplémentaire d'équipement",
        "detail_distractors": ["Une augmentation de cotisation", "Une sélection sur dossier", "Une formation obligatoire pour les parents"],
    },
    {
        "text": "Une entreprise de recyclage a installé des bornes de tri des déchets électroniques dans les quartiers. Chaque borne identifie le type d'appareil et délivre un bon d'achat en échange du dépôt.",
        "main_answer": "Collecter les déchets électroniques via des bornes",
        "main_distractors": ["Vendre des appareils reconditionnés", "Installer des bornes de recharge", "Organiser des ateliers de programmation"],
        "detail_question": "Que reçoit le déposant ?",
        "detail_answer": "Un bon d'achat",
        "detail_distractors": ["Un ticket de parking", "Un abonnement internet", "Une carte de fidélité bancaire"],
    },
    {
        "text": "Le service météorologique national diffuse désormais des bulletins ciblés pour les agriculteurs. Les prévisions incluent des conseils sur l'irrigation et la protection des cultures.",
        "main_answer": "Adapter les bulletins météo aux besoins agricoles",
        "main_distractors": ["Prévoir les trafics aériens", "Informer sur les compétitions sportives", "Publier des horoscopes"],
        "detail_question": "Quels conseils accompagnent les prévisions ?",
        "detail_answer": "Des recommandations d'irrigation et de protection des cultures",
        "detail_distractors": ["Des cours de cuisine", "Des informations fiscales", "Des offres d'emploi"],
    },
    {
        "text": "Une agence de voyage solidaire propose des séjours où les touristes participent à la rénovation d'écoles. Les programmes incluent également des rencontres avec les associations locales.",
        "main_answer": "Organiser des séjours solidaires autour de la rénovation d'écoles",
        "main_distractors": ["Ouvrir des hôtels de luxe", "Promouvoir exclusivement des croisières", "Remplacer les guides par des applications"],
        "detail_question": "Quelle activité complète la rénovation ?",
        "detail_answer": "Des rencontres avec les associations locales",
        "detail_distractors": ["Des visites d'usines", "Des formations comptables", "Des cours de langue obligatoires"],
    },
    {
        "text": "Pour encourager l'innovation, une banque accorde des microcrédits à taux réduit aux porteurs de projets verts. Les dossiers sont accompagnés d'un mentorat financier pendant la première année.",
        "main_answer": "Financer des projets verts avec des microcrédits",
        "main_distractors": ["Augmenter les taux d'intérêt", "Investir uniquement dans l'immobilier", "Spéculer sur les matières premières"],
        "detail_question": "Quel accompagnement est prévu ?",
        "detail_answer": "Un mentorat financier la première année",
        "detail_distractors": ["Une exonération fiscale", "Un partenariat juridique", "Un audit informatique"],
    },
    {
        "text": "Une association d'alphabétisation organise des cours du soir pour les adultes récemment installés en ville. Les séances alternent lecture, écriture et mise en situation dans les services publics.",
        "main_answer": "Proposer des cours du soir aux nouveaux arrivants",
        "main_distractors": ["Créer une école primaire privée", "Former des traducteurs professionnels", "Ouvrir une maison d'édition"],
        "detail_question": "Quelles activités complètent la lecture et l'écriture ?",
        "detail_answer": "Des mises en situation dans les services publics",
        "detail_distractors": ["Des cours de cuisine", "Des entraînements sportifs", "Des ateliers de couture"],
    },
]

ORTHO_ENTRIES = [
    {
        "sentence": "____-vous reçu les rapports hier ?",
        "choices_fill": ["Avez", "Auriez", "Aviez", "Auront"],
        "fill_index": 0,
        "explanation_fill": "À la forme interrogative inversée, on écrit 'Avez-vous'.",
        "detail_question": "Quel temps est employé dans la bonne réponse ?",
        "detail_choices": ["Présent de l'indicatif", "Imparfait", "Futur", "Passé simple"],
        "detail_index": 0,
        "explanation_detail": "'Avez' est conjugué au présent de l'indicatif.",
    },
    {
        "sentence": "Les dossiers ont été ____ avec soin.",
        "choices_fill": ["traités", "traité", "traitée", "traitées"],
        "fill_index": 0,
        "explanation_fill": "Le participe passé s'accorde avec le COD 'les dossiers'.",
        "detail_question": "Quel est le genre du mot 'dossiers' ?",
        "detail_choices": ["Masculin pluriel", "Féminin singulier", "Masculin singulier", "Féminin pluriel"],
        "detail_index": 0,
        "explanation_detail": "'Dossiers' est masculin pluriel, d'où l'accord.",
    },
    {
        "sentence": "Il faut que vous ____ votre demande par écrit.",
        "choices_fill": ["fassiez", "faisiez", "faite", "faits"],
        "fill_index": 0,
        "explanation_fill": "Après 'il faut que', on emploie le subjonctif présent : 'fassiez'.",
        "detail_question": "Quel mode suit l'expression 'il faut que' ?",
        "detail_choices": ["Subjonctif", "Indicatif", "Conditionnel", "Impératif"],
        "detail_index": 0,
        "explanation_detail": "'Il faut que' appelle le subjonctif.",
    },
    {
        "sentence": "Nous avons consulté les experts ____ l'avis était attendu.",
        "choices_fill": ["dont", "que", "qui", "où"],
        "fill_index": 0,
        "explanation_fill": "'Dont' remplace 'de qui' dans une relative de possession.",
        "detail_question": "Quel pronom relatif exprime la possession ?",
        "detail_choices": ["Dont", "Qui", "Que", "Lequel"],
        "detail_index": 0,
        "explanation_detail": "Le pronom 'dont' exprime la possession.",
    },
    {
        "sentence": "Ils se sont ____ la main en signe d'accord.",
        "choices_fill": ["serré", "serrés", "serrée", "serrées"],
        "fill_index": 0,
        "explanation_fill": "Avec l'auxiliaire 'être' et un COD placé après, le participe passé reste invariable.",
        "detail_question": "Quel auxiliaire est utilisé ici ?",
        "detail_choices": ["Être", "Avoir", "Faire", "Aller"],
        "detail_index": 0,
        "explanation_detail": "'Se sont' correspond à l'auxiliaire être.",
    },
    {
        "sentence": "La réunion ____ demain matin à huit heures.",
        "choices_fill": ["aura lieu", "aurait lieu", "a lieu", "eut lieu"],
        "fill_index": 0,
        "explanation_fill": "On exprime un futur certain avec 'aura lieu'.",
        "detail_question": "Quel temps utilise-t-on pour exprimer un futur programmé ?",
        "detail_choices": ["Futur simple", "Conditionnel", "Imparfait", "Passé simple"],
        "detail_index": 0,
        "explanation_detail": "Le futur simple convient pour un événement prévu.",
    },
    {
        "sentence": "Voici les résultats ____ nous disposions déjà.",
        "choices_fill": ["dont", "que", "qui", "auxquels"],
        "fill_index": 0,
        "explanation_fill": "'Dont' remplace 'de' + nom pour indiquer la possession d'information.",
        "detail_question": "Quel verbe dans la phrase exige la préposition 'de' ?",
        "detail_choices": ["Disposer", "Recevoir", "Comparer", "Ajouter"],
        "detail_index": 0,
        "explanation_detail": "On dispose de quelque chose, d'où 'dont'.",
    },
    {
        "sentence": "Ces données ont été ____ conformément aux procédures.",
        "choices_fill": ["vérifiées", "vérifié", "vérifiée", "vérifiés"],
        "fill_index": 0,
        "explanation_fill": "Le COD 'données' est féminin pluriel, le participe passé s'accorde donc.",
        "detail_question": "Quel type de mot est 'conformément' ?",
        "detail_choices": ["Adverbe", "Adjectif", "Nom", "Préposition"],
        "detail_index": 0,
        "explanation_detail": "'Conformément' est un adverbe.",
    },
    {
        "sentence": "Si nous ____ plus de temps, nous approfondirions l'étude.",
        "choices_fill": ["avions", "aurions", "avons", "eûmes"],
        "fill_index": 0,
        "explanation_fill": "Dans une hypothèse irréelle, on emploie l'imparfait dans la proposition introduite par 'si'.",
        "detail_question": "Quel temps suit la conjonction 'si' dans une hypothèse irréelle ?",
        "detail_choices": ["Imparfait", "Présent", "Futur", "Subjonctif"],
        "detail_index": 0,
        "explanation_detail": "On utilise l'imparfait dans la subordonnée pour un irréel.",
    },
    {
        "sentence": "Elles se sont ____ compte de l'erreur après coup.",
        "choices_fill": ["rendu", "rendues", "rendus", "rendue"],
        "fill_index": 1,
        "explanation_fill": "'Se rendre compte' s'accorde avec le sujet féminin pluriel puisqu'il n'y a pas de COD.",
        "detail_question": "Quel est le genre et le nombre du sujet ?",
        "detail_choices": ["Féminin pluriel", "Masculin singulier", "Masculin pluriel", "Féminin singulier"],
        "detail_index": 0,
        "explanation_detail": "Le sujet 'elles' est féminin pluriel.",
    },
    {
        "sentence": "Nous voulons des rapports ____ soient synthétiques.",
        "choices_fill": ["qui", "que", "dont", "où"],
        "fill_index": 0,
        "explanation_fill": "Le pronom relatif sujet adéquat est 'qui'.",
        "detail_question": "Quelle fonction occupe 'qui' dans la relative ?",
        "detail_choices": ["Sujet", "COD", "COI", "Attribut"],
        "detail_index": 0,
        "explanation_detail": "'Qui' est sujet du verbe 'soient'.",
    },
    {
        "sentence": "Le directeur, ainsi que ses adjoints, ____ conviés à la conférence.",
        "choices_fill": ["sont", "est", "seront", "étaient"],
        "fill_index": 0,
        "explanation_fill": "Le verbe s'accorde avec le sujet principal 'le directeur'.",
        "detail_question": "Quel est le noyau du groupe sujet ?",
        "detail_choices": ["Le directeur", "Ses adjoints", "Le directeur et ses adjoints", "La conférence"],
        "detail_index": 0,
        "explanation_detail": "Le noyau est 'le directeur'; 'ainsi que ses adjoints' est un ajout.",
    },
    {
        "sentence": "Vous trouverez ci-joint les documents ____ avez demandés.",
        "choices_fill": ["que vous", "qui vous", "dont vous", "où vous"],
        "fill_index": 0,
        "explanation_fill": "'Que vous' est nécessaire pour reprendre le COD placé après.",
        "detail_question": "Quel est le rôle de 'que' dans cette phrase ?",
        "detail_choices": ["COD", "Sujet", "Complément circonstanciel", "Attribut"],
        "detail_index": 0,
        "explanation_detail": "'Que' remplace le COD 'les documents'.",
    },
    {
        "sentence": "Elle a procédé aux vérifications ____ rigueur.",
        "choices_fill": ["avec", "d'", "sans", "par"],
        "fill_index": 0,
        "explanation_fill": "L'expression figée est 'avec rigueur'.",
        "detail_question": "Quel type d'expression est 'avec rigueur' ?",
        "detail_choices": ["Locution adverbiale", "Locution verbale", "Locution adjectivale", "Locution conjonctive"],
        "detail_index": 0,
        "explanation_detail": "Il s'agit d'une locution adverbiale.",
    },
    {
        "sentence": "Ils partiront dès que nous ____ prêts.",
        "choices_fill": ["serons", "sommes", "étions", "serions"],
        "fill_index": 0,
        "explanation_fill": "Avec 'dès que', on emploie le futur dans la principale et le futur antérieur ou présent dans la subordonnée selon le sens; ici, le futur simple convient.",
        "detail_question": "Quel temps suit généralement 'dès que' pour exprimer l'avenir ?",
        "detail_choices": ["Futur", "Imparfait", "Conditionnel", "Subjonctif"],
        "detail_index": 0,
        "explanation_detail": "Le futur simple est utilisé pour un événement à venir certain.",
    },
    {
        "sentence": "Nous avons obtenu les autorisations ____ dépendait notre projet.",
        "choices_fill": ["dont", "que", "qui", "où"],
        "fill_index": 0,
        "explanation_fill": "'Dont' est nécessaire car le verbe 'dépendre' se construit avec 'de'.",
        "detail_question": "Quelle préposition accompagne le verbe 'dépendre' ?",
        "detail_choices": ["De", "À", "Pour", "Vers"],
        "detail_index": 0,
        "explanation_detail": "On dit dépendre de quelque chose.",
    },
    {
        "sentence": "Ces mesures sont ____ la responsabilité du préfet.",
        "choices_fill": ["sous", "dans", "sur", "par"],
        "fill_index": 0,
        "explanation_fill": "On emploie l'expression 'sous la responsabilité'.",
        "detail_question": "Quel est le nom régissant la préposition dans cette expression ?",
        "detail_choices": ["Responsabilité", "Mesures", "Préfet", "Expression"],
        "detail_index": 0,
        "explanation_detail": "C'est 'responsabilité' qui régit la préposition.",
    },
    {
        "sentence": "La solution qu'ils ont ____ semble efficace.",
        "choices_fill": ["choisie", "choisi", "choisies", "choisis"],
        "fill_index": 0,
        "explanation_fill": "Le COD 'solution' est placé avant, le participe passé s'accorde donc en genre et en nombre.",
        "detail_question": "Avec quel auxiliaire est conjugué le verbe 'choisir' dans cette phrase ?",
        "detail_choices": ["Avoir", "Être", "Faire", "Devoir"],
        "detail_index": 0,
        "explanation_detail": "Le verbe est conjugué avec l'auxiliaire avoir.",
    },
    {
        "sentence": "Nous ignorons ____ viendra représenter l'association.",
        "choices_fill": ["qui", "que", "dont", "lequel"],
        "fill_index": 0,
        "explanation_fill": "La subordonnée interrogative indirecte commence par 'qui'.",
        "detail_question": "Quel type de subordonnée est introduit par cette conjonction ?",
        "detail_choices": ["Interrogative indirecte", "Relative", "Complétive conjonctive", "Subordonnée circonstancielle"],
        "detail_index": 0,
        "explanation_detail": "Il s'agit d'une interrogative indirecte.",
    },
    {
        "sentence": "Elles ont achevé les tâches ____ elles étaient chargées.",
        "choices_fill": ["dont", "que", "auxquelles", "par lesquelles"],
        "fill_index": 2,
        "explanation_fill": "'Être chargé de' impose la préposition 'de', on utilise donc 'dont' ou 'auxquelles'; ici le nom est féminin pluriel, 'auxquelles' convient.",
        "detail_question": "Quelle est la préposition exigée par 'être chargé' ?",
        "detail_choices": ["De", "À", "Sur", "En"],
        "detail_index": 0,
        "explanation_detail": "On est chargé de quelque chose.",
    },
    {
        "sentence": "Je crains que la décision ne ____ reportée.",
        "choices_fill": ["soit", "est", "sera", "serait"],
        "fill_index": 0,
        "explanation_fill": "Après 'je crains que', on emploie le subjonctif présent.",
        "detail_question": "Quel mot marque ici la négation explétive ?",
        "detail_choices": ["Ne", "Que", "La", "Décision"],
        "detail_index": 0,
        "explanation_detail": "Le 'ne' devant 'soit' est explétif et n'exprime pas la négation réelle.",
    },
    {
        "sentence": "Les rapports, ainsi que les annexes, ____ été transmis.",
        "choices_fill": ["ont", "a", "eurent", "auront"],
        "fill_index": 0,
        "explanation_fill": "Le sujet est pluriel ('les rapports... les annexes'), le verbe prend la forme plurielle 'ont'.",
        "detail_question": "Quelle tournure relie les deux éléments du sujet ?",
        "detail_choices": ["Ainsi que", "Tandis que", "Parce que", "Alors que"],
        "detail_index": 0,
        "explanation_detail": "'Ainsi que' relie deux éléments coordonnés.",
    },
    {
        "sentence": "Nous avons conclu l'accord ____ vous étiez favorable.",
        "choices_fill": ["auquel", "duquel", "lequel", "dans lequel"],
        "fill_index": 0,
        "explanation_fill": "Le nom masculin 'accord' nécessite 'auquel' pour reprendre 'à l'accord'.",
        "detail_question": "Quelle préposition est sous-entendue dans 'auquel' ?",
        "detail_choices": ["À", "De", "Pour", "Vers"],
        "detail_index": 0,
        "explanation_detail": "'Auquel' correspond à 'à lequel'.",
    },
    {
        "sentence": "Les membres présents ont signé le registre ____ deux exemplaires.",
        "choices_fill": ["en", "à", "de", "par"],
        "fill_index": 0,
        "explanation_fill": "'En deux exemplaires' est l'expression correcte.",
        "detail_question": "Quel type de complément représente 'en deux exemplaires' ?",
        "detail_choices": ["Complément circonstanciel", "COD", "COI", "Attribut"],
        "detail_index": 0,
        "explanation_detail": "Il s'agit d'un complément circonstanciel de manière.",
    },
    {
        "sentence": "Il s'agit des pièces ____ nous avons besoin pour le dossier.",
        "choices_fill": ["dont", "que", "qui", "où"],
        "fill_index": 0,
        "explanation_fill": "'Avoir besoin de' impose le pronom 'dont'.",
        "detail_question": "Quelle construction suit le verbe 'avoir besoin' ?",
        "detail_choices": ["De + nom", "À + infinitif", "Pour + nom", "Avec + nom"],
        "detail_index": 0,
        "explanation_detail": "On dit avoir besoin de quelque chose.",
    },
]

EXPR_ENTRIES = [
    {
        "situation": "Le rapport souligne l'augmentation des coûts, _____ il propose de mutualiser les achats.",
        "connector_choices": ["c'est pourquoi", "néanmoins", "pourtant", "cependant"],
        "connector_index": 0,
        "connector_explanation": "'C'est pourquoi' exprime une conséquence logique.",
        "rewrite_choices": [
            "Le rapport constate la hausse des coûts et recommande la mutualisation des achats.",
            "Le rapport nie la hausse des coûts mais évoque la mutualisation.",
            "Le rapport détaille les coûts sans proposer de solution.",
            "Le rapport présente la mutualisation comme une contrainte imposée.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation conserve la relation de cause à effet.",
    },
    {
        "situation": "Les équipes ont respecté le calendrier, _____ elles ont dû travailler certains week-ends.",
        "connector_choices": ["bien que", "car", "de sorte que", "ainsi"],
        "connector_index": 0,
        "connector_explanation": "'Bien que' introduit une concession.",
        "rewrite_choices": [
            "Même en travaillant certains week-ends, les équipes ont tenu le calendrier.",
            "Les équipes ont abandonné le calendrier pour éviter les week-ends.",
            "Les équipes ont travaillé le week-end pour retarder le calendrier.",
            "Les équipes n'ont pas tenu le calendrier malgré les week-ends.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation souligne l'effort réalisé.",
    },
    {
        "situation": "Nous avons rencontré les partenaires, _____ définir les priorités communes.",
        "connector_choices": ["afin de", "tandis que", "malgré", "en revanche"],
        "connector_index": 0,
        "connector_explanation": "'Afin de' exprime le but.",
        "rewrite_choices": [
            "La rencontre avec les partenaires a permis de fixer des priorités partagées.",
            "Les priorités ont été imposées sans concertation.",
            "Aucune rencontre n'a eu lieu avec les partenaires.",
            "Les partenaires ont refusé de définir des priorités.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation rappelle l'objectif de la réunion.",
    },
    {
        "situation": "La collectivité dispose d'un budget limité, _____ elle priorise les investissements urgents.",
        "connector_choices": ["donc", "cependant", "pourtant", "sinon"],
        "connector_index": 0,
        "connector_explanation": "'Donc' marque la conséquence.",
        "rewrite_choices": [
            "Le budget restreint oblige la collectivité à se concentrer sur l'urgence.",
            "La collectivité multiplie les projets secondaires faute de budget.",
            "La collectivité reporte tous les investissements sans exception.",
            "La collectivité augmente ses dépenses malgré le manque de budget.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation conserve l'idée de contrainte.",
    },
    {
        "situation": "Les indicateurs sont encourageants; _____, nous restons vigilants sur les risques.",
        "connector_choices": ["néanmoins", "par conséquent", "de plus", "car"],
        "connector_index": 0,
        "connector_explanation": "'Néanmoins' introduit une réserve.",
        "rewrite_choices": [
            "Même si les indicateurs sont bons, la vigilance demeure.",
            "Les indicateurs sont bons, donc la vigilance disparaît.",
            "Les indicateurs sont mauvais, pourtant la vigilance baisse.",
            "La vigilance augmente parce que les indicateurs sont négligés.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation maintient l'opposition encouragement/prudence.",
    },
    {
        "situation": "Le comité a validé la stratégie, _____ il a demandé un suivi trimestriel.",
        "connector_choices": ["par ailleurs", "cependant", "sinon", "tandis que"],
        "connector_index": 0,
        "connector_explanation": "'Par ailleurs' ajoute une information.",
        "rewrite_choices": [
            "Le comité approuve la stratégie et souhaite un suivi tous les trimestres.",
            "Le comité rejette la stratégie faute de suivi.",
            "La stratégie est validée sans aucun suivi.",
            "Le suivi trimestriel remplace la stratégie validée.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation associe validation et suivi.",
    },
    {
        "situation": "Le diagnostic a été partagé avec les équipes, _____ chacun a pu proposer des solutions.",
        "connector_choices": ["de sorte que", "alors que", "cependant", "malgré"],
        "connector_index": 0,
        "connector_explanation": "'De sorte que' exprime la conséquence.",
        "rewrite_choices": [
            "Après la présentation du diagnostic, les équipes ont formulé leurs solutions.",
            "Les solutions ont été imposées sans diagnostic.",
            "Le diagnostic a été caché aux équipes qui ont travaillé seules.",
            "Les équipes ont refusé de proposer des solutions.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation garde le lien causal.",
    },
    {
        "situation": "Les bénévoles ont reçu une formation en ligne, _____ ils pouvaient intervenir rapidement.",
        "connector_choices": ["ainsi", "pourtant", "cependant", "quoique"],
        "connector_index": 0,
        "connector_explanation": "'Ainsi' présente la conséquence positive.",
        "rewrite_choices": [
            "Grâce à la formation en ligne, les bénévoles ont pu intervenir sans délai.",
            "La formation en ligne a retardé l'intervention.",
            "Les bénévoles ont refusé la formation mais sont intervenus.",
            "La formation a été annulée faute de participants.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation insiste sur l'efficacité de la formation.",
    },
    {
        "situation": "Le rapport insiste sur l'éthique, _____ chaque décision doit être argumentée.",
        "connector_choices": ["en conséquence", "pourtant", "malgré tout", "sinon"],
        "connector_index": 0,
        "connector_explanation": "'En conséquence' indique la conclusion logique.",
        "rewrite_choices": [
            "Parce que l'éthique est centrale, toute décision doit être motivée.",
            "L'éthique est secondaire et ne nécessite aucune justification.",
            "Les décisions peuvent rester implicites malgré l'éthique.",
            "L'éthique empêche de justifier les décisions.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation relie l'éthique à l'obligation d'argumenter.",
    },
    {
        "situation": "Les délais étaient serrés, _____ nous avons externalisé une partie de la production.",
        "connector_choices": ["c'est pourquoi", "au contraire", "pourtant", "néanmoins"],
        "connector_index": 0,
        "connector_explanation": "'C'est pourquoi' justifie la décision.",
        "rewrite_choices": [
            "En raison des délais serrés, une partie de la production a été confiée à un prestataire.",
            "Les délais serrés nous ont conduits à refuser toute externalisation.",
            "Les délais larges nous ont poussés à externaliser.",
            "Les délais serrés ont rallongé la production interne.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation conserve le lien causal.",
    },
    {
        "situation": "Le comité a retenu trois projets, _____ ils répondent aux critères sociaux et environnementaux.",
        "connector_choices": ["car", "mais", "toutefois", "sinon"],
        "connector_index": 0,
        "connector_explanation": "'Car' expose la cause.",
        "rewrite_choices": [
            "Les trois projets choisis respectent les critères sociaux et environnementaux.",
            "Les projets retenus ne respectent aucun critère.",
            "Les projets ont été rejetés malgré leur conformité.",
            "Les critères n'ont pas été étudiés.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation rappelle la justification.",
    },
    {
        "situation": "Les candidats doivent déposer un dossier complet, _____ ils seront auditionnés.",
        "connector_choices": ["puis", "cependant", "sinon", "car"],
        "connector_index": 0,
        "connector_explanation": "'Puis' marque la chronologie.",
        "rewrite_choices": [
            "Après le dépôt du dossier complet, les candidats passent une audition.",
            "Les candidats sont auditionnés avant de déposer le dossier.",
            "Aucun dossier n'est requis pour l'audition.",
            "Seuls les dossiers incomplets donnent lieu à une audition.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation respecte l'ordre des étapes.",
    },
    {
        "situation": "La direction a accepté le compromis, _____ elle a fixé une clause de révision annuelle.",
        "connector_choices": ["à condition de", "tandis que", "pourtant", "sinon"],
        "connector_index": 0,
        "connector_explanation": "'À condition de' introduit la réserve.",
        "rewrite_choices": [
            "La direction accepte le compromis sous réserve d'une révision annuelle.",
            "La direction rejette le compromis faute de clause.",
            "Le compromis est accepté sans condition.",
            "La clause annuelle remplace le compromis.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation précise l'accord conditionnel.",
    },
    {
        "situation": "Le projet a été suspendu, _____ les financements ne sont pas encore confirmés.",
        "connector_choices": ["car", "pourtant", "ainsi", "de plus"],
        "connector_index": 0,
        "connector_explanation": "'Car' explique la suspension.",
        "rewrite_choices": [
            "Le projet est suspendu en attendant la confirmation des financements.",
            "Le projet se poursuit malgré l'absence de financements.",
            "Les financements confirmés accélèrent le projet.",
            "Le projet est suspendu même si les financements sont confirmés.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation maintient la relation cause-conséquence.",
    },
    {
        "situation": "La synthèse doit être concise, _____ exhaustive sur les enjeux principaux.",
        "connector_choices": ["mais", "car", "sinon", "pour"],
        "connector_index": 0,
        "connector_explanation": "'Mais' nuance la consigne.",
        "rewrite_choices": [
            "La synthèse doit rester brève tout en couvrant les enjeux essentiels.",
            "La synthèse peut ignorer les enjeux pour rester concise.",
            "La synthèse doit être longue pour couvrir tous les enjeux.",
            "La synthèse abandonne l'exhaustivité pour rester concise.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation reprend la nuance exigée.",
    },
    {
        "situation": "Les habitants ont soutenu le projet, _____ certains craignaient une hausse des loyers.",
        "connector_choices": ["même si", "ainsi", "car", "donc"],
        "connector_index": 0,
        "connector_explanation": "'Même si' exprime la concession.",
        "rewrite_choices": [
            "Malgré la crainte d'une hausse des loyers, les habitants ont soutenu le projet.",
            "La hausse des loyers a conduit les habitants à rejeter le projet.",
            "Les habitants ont soutenu le projet pour augmenter les loyers.",
            "Les habitants ont rejeté tout projet pour conserver les loyers.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation maintient la concession.",
    },
    {
        "situation": "Les audits sont terminés, _____ nous pouvons lancer l'appel d'offres.",
        "connector_choices": ["désormais", "pourtant", "sinon", "mais"],
        "connector_index": 0,
        "connector_explanation": "'Désormais' marque le changement d'étape.",
        "rewrite_choices": [
            "Les audits étant achevés, l'appel d'offres peut débuter.",
            "Avant la fin des audits, l'appel d'offres a été lancé.",
            "Les audits terminés empêchent l'appel d'offres.",
            "L'appel d'offres précède toujours la fin des audits.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation respecte la chronologie.",
    },
    {
        "situation": "Le comité a reporté sa décision, _____ il attend les résultats des consultations.",
        "connector_choices": ["parce que", "mais", "cependant", "sinon"],
        "connector_index": 0,
        "connector_explanation": "'Parce que' donne la raison.",
        "rewrite_choices": [
            "La décision est reportée dans l'attente des conclusions des consultations.",
            "La décision est prise avant les consultations.",
            "Les consultations sont terminées et la décision est maintenue.",
            "La décision est reportée bien que les consultations soient closes.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation rappelle la cause du report.",
    },
    {
        "situation": "Les formations sont ouvertes à tous, _____ une inscription préalable est obligatoire.",
        "connector_choices": ["mais", "car", "ainsi", "donc"],
        "connector_index": 0,
        "connector_explanation": "'Mais' ajoute une restriction.",
        "rewrite_choices": [
            "Les formations sont accessibles, à condition de s'inscrire au préalable.",
            "Les formations sont libres sans inscription.",
            "Aucune inscription n'est possible pour les formations.",
            "Les formations sont fermées malgré les inscriptions.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation conserve l'ouverture conditionnelle.",
    },
    {
        "situation": "Le service a communiqué le planning, _____ chacun organise son travail.",
        "connector_choices": ["afin que", "pourtant", "néanmoins", "cependant"],
        "connector_index": 0,
        "connector_explanation": "'Afin que' exprime le but.",
        "rewrite_choices": [
            "Le planning a été communiqué pour que chacun organise son travail.",
            "Le planning est resté confidentiel pour organiser le travail.",
            "Le planning a été communiqué sans objectif.",
            "L'organisation du travail se fait sans planning.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation garde la finalité du partage.",
    },
    {
        "situation": "Les partenaires ont signé le protocole, _____ ils s'engagent à publier un rapport annuel.",
        "connector_choices": ["et", "mais", "sinon", "or"],
        "connector_index": 0,
        "connector_explanation": "'Et' relie deux actions complémentaires.",
        "rewrite_choices": [
            "Les partenaires signataires s'engagent également à publier un rapport annuel.",
            "Les partenaires refusent de publier un rapport malgré la signature.",
            "La signature dispense de publier un rapport.",
            "Le protocole est signé pour éviter toute publication.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation associe signature et engagement.",
    },
    {
        "situation": "Les stocks ont diminué, _____ nous avons déclenché le réapprovisionnement.",
        "connector_choices": ["si bien que", "tandis que", "quoique", "pourtant"],
        "connector_index": 0,
        "connector_explanation": "'Si bien que' exprime la conséquence.",
        "rewrite_choices": [
            "La baisse des stocks a conduit au lancement d'un réapprovisionnement.",
            "Le réapprovisionnement a été lancé malgré des stocks élevés.",
            "Les stocks ont augmenté grâce au réapprovisionnement.",
            "Le réapprovisionnement a provoqué la baisse des stocks.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation conserve le lien de causalité.",
    },
    {
        "situation": "Le plan d'action est ambitieux, _____ il reste réaliste pour les équipes.",
        "connector_choices": ["mais", "car", "donc", "pour"],
        "connector_index": 0,
        "connector_explanation": "'Mais' nuance l'ambition.",
        "rewrite_choices": [
            "Bien qu'ambitieux, le plan demeure réaliste pour les équipes.",
            "Le plan ambitieux dépasse les capacités des équipes.",
            "Le plan réaliste n'a aucune ambition.",
            "Le plan abandonne l'ambition pour rester réaliste.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation met en valeur l'équilibre.",
    },
    {
        "situation": "Le directeur a remercié les agents, _____ il a rappelé les objectifs de l'année.",
        "connector_choices": ["puis", "tandis que", "cependant", "malgré"],
        "connector_index": 0,
        "connector_explanation": "'Puis' indique la succession.",
        "rewrite_choices": [
            "Après les remerciements, le directeur a rappelé les objectifs annuels.",
            "Le directeur a rappelé les objectifs avant de remercier.",
            "Le directeur a remercié sans évoquer les objectifs.",
            "Les objectifs ont été oubliés au profit des remerciements.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation respecte l'ordre des actions.",
    },
    {
        "situation": "Les services ont mené une phase de test, _____ ils ajusteront l'outil avant le déploiement.",
        "connector_choices": ["puis", "cependant", "tandis que", "pourtant"],
        "connector_index": 0,
        "connector_explanation": "'Puis' marque la succession.",
        "rewrite_choices": [
            "Après la phase de test, les services ajusteront l'outil avant le déploiement.",
            "Les services déploient l'outil sans phase de test.",
            "Les ajustements ont lieu avant toute phase de test.",
            "La phase de test remplace le déploiement.",
        ],
        "rewrite_index": 0,
        "rewrite_explanation": "La reformulation reprend la chronologie des actions.",
    },
]


LOGIC_PEOPLE = [
    "Awa",
    "Boris",
    "Chantal",
    "Diego",
    "Élodie",
    "Fabrice",
    "Gisèle",
    "Hector",
    "Irène",
    "Jules",
    "Kadi",
    "Lamine",
    "Mina",
    "Noé",
    "Oumou",
    "Prisca",
    "Quentin",
    "Rokia",
    "Salim",
    "Tania",
    "Ulrich",
    "Valérie",
    "Wilfried",
    "Xavier",
    "Yasmine",
    "Zacharie",
]

LOGIC_CONTEXTS = [
    ("l'ordre de passage des candidats", "candidat"),
    ("la planification des inspections", "inspection"),
    ("la priorisation des dossiers", "dossier"),
    ("l'organisation des interventions", "équipe"),
    ("la rotation des gardes", "agent"),
]


def make_logic_classments(total=200, start_id=7001):
    questions = []
    counter = count(start_id)
    for idx in range(total):
        names = [LOGIC_PEOPLE[(idx + offset) % len(LOGIC_PEOPLE)] for offset in range(4)]
        shift = idx % 4
        order = names[shift:] + names[:shift]
        context, _ = LOGIC_CONTEXTS[idx % len(LOGIC_CONTEXTS)]
        participants = ", ".join(order[:-1]) + f" et {order[-1]}"
        statements = []
        prompt = ""
        if idx % 4 == 0:
            statements = [
                f"{order[0]} précède {order[1]} et {order[2]}",
                f"{order[1]} arrive avant {order[2]}",
                f"{order[3]} est placé juste après {order[2]}",
            ]
            prompt = "Qui occupe la deuxième position ?"
            correct = order[1]
        elif idx % 4 == 1:
            statements = [
                f"{order[0]} est le seul à précéder {order[1]}",
                f"{order[2]} suit immédiatement {order[1]}",
                f"{order[3]} ferme la marche",
            ]
            prompt = "Qui arrive en troisième position ?"
            correct = order[2]
        elif idx % 4 == 2:
            statements = [
                f"{order[1]} est placé juste après {order[0]}",
                f"{order[2]} précède {order[3]}",
                f"{order[0]} reste devant tous les autres",
            ]
            prompt = "Qui occupe la première place ?"
            correct = order[0]
        else:
            statements = [
                f"{order[0]} précède {order[2]}",
                f"{order[1]} est classé avant {order[2]}",
                f"Seul {order[3]} arrive après {order[2]}",
            ]
            prompt = "Qui termine en dernière position ?"
            correct = order[3]
        description = (
            f"Dans {context}, {participants} doivent être ordonnés.\n"
            + "\n".join(f"- {statement}." for statement in statements)
            + f"\n{prompt}"
        )
        distractors = [name for name in order if name != correct]
        questions.append(
            {
                "id": f"OL-CD-{next(counter):04d}",
                "concours": "ENA",
                "subject": "Organisation & Logique",
                "chapter": "Classements & déductions",
                "difficulty": 1 + (idx % 3),
                "question": description,
                "choices": [correct] + distractors,
                "answerIndex": 0,
                "explanation": (
                    f"Les contraintes imposent l'ordre {order[0]}, {order[1]}, {order[2]}, {order[3]}; "
                    f"{correct} répond donc à la question."
                ),
            }
        )
    return questions


def generate_organisation_logique():
    return make_logic_classments()


def build_all_questions():
    existing = parse_existing(DATA_FILE)
    droit = generate_droit_constitutionnel()
    economie = generate_problemes_economiques()
    numerique = generate_aptitude_numerique()
    verbale = generate_aptitude_verbale()
    logique = generate_organisation_logique()
    combined = existing + droit + economie + numerique + verbale + logique
    ids = [q["id"] for q in combined]
    if len(ids) != len(set(ids)):
        raise ValueError("Duplicate question IDs detected")
    return combined


def main():
    questions = build_all_questions()
    with DATA_FILE.open("w", encoding="utf-8") as fh:
        json.dump(questions, fh, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
