import json
import random
from pathlib import Path

random.seed(20241005)

countries = [
    {
        "country": "Afrique du Sud",
        "capital": "Pretoria",
        "seat_of_government": "Pretoria",
        "currency": "rand sud-africain",
        "independence_year": 1910,
        "official_languages": ["anglais", "afrikaans", "zoulou", "xhosa"],
        "largest_city": "Johannesburg",
        "regional_bloc": "SADC"
    },
    {
        "country": "Algérie",
        "capital": "Alger",
        "currency": "dinar algérien",
        "independence_year": 1962,
        "official_languages": ["arabe", "tamazight"],
        "largest_city": "Alger",
        "regional_bloc": "UMA"
    },
    {
        "country": "Angola",
        "capital": "Luanda",
        "currency": "kwanza angolais",
        "independence_year": 1975,
        "official_languages": ["portugais"],
        "largest_city": "Luanda",
        "regional_bloc": "SADC"
    },
    {
        "country": "Bénin",
        "capital": "Porto-Novo",
        "seat_of_government": "Cotonou",
        "currency": "franc CFA BCEAO",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Cotonou",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Botswana",
        "capital": "Gaborone",
        "currency": "pula botswanais",
        "independence_year": 1966,
        "official_languages": ["anglais", "setswana"],
        "largest_city": "Gaborone",
        "regional_bloc": "SADC"
    },
    {
        "country": "Burkina Faso",
        "capital": "Ouagadougou",
        "currency": "franc CFA BCEAO",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Ouagadougou",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Burundi",
        "capital": "Gitega",
        "currency": "franc burundais",
        "independence_year": 1962,
        "official_languages": ["kirundi", "français", "anglais"],
        "largest_city": "Bujumbura",
        "regional_bloc": "CAE"
    },
    {
        "country": "Cabo Verde",
        "capital": "Praia",
        "currency": "escudo cap-verdien",
        "independence_year": 1975,
        "official_languages": ["portugais"],
        "largest_city": "Praia",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Cameroun",
        "capital": "Yaoundé",
        "currency": "franc CFA BEAC",
        "independence_year": 1960,
        "official_languages": ["français", "anglais"],
        "largest_city": "Douala",
        "regional_bloc": "CEEAC"
    },
    {
        "country": "Comores",
        "capital": "Moroni",
        "currency": "franc comorien",
        "independence_year": 1975,
        "official_languages": ["arabe", "français", "comorien"],
        "largest_city": "Moroni",
        "regional_bloc": "COI"
    },
    {
        "country": "Congo",
        "capital": "Brazzaville",
        "currency": "franc CFA BEAC",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Brazzaville",
        "regional_bloc": "CEEAC"
    },
    {
        "country": "Côte d’Ivoire",
        "capital": "Yamoussoukro",
        "seat_of_government": "Abidjan",
        "currency": "franc CFA BCEAO",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Abidjan",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Djibouti",
        "capital": "Djibouti",
        "currency": "franc djiboutien",
        "independence_year": 1977,
        "official_languages": ["français", "arabe"],
        "largest_city": "Djibouti",
        "regional_bloc": "IGAD"
    },
    {
        "country": "Égypte",
        "capital": "Le Caire",
        "currency": "livre égyptienne",
        "independence_year": 1922,
        "official_languages": ["arabe"],
        "largest_city": "Le Caire",
        "regional_bloc": "COMESA"
    },
    {
        "country": "Érythrée",
        "capital": "Asmara",
        "currency": "nafka érythréen",
        "independence_year": 1993,
        "official_languages": ["tigrinya", "arabe", "anglais"],
        "largest_city": "Asmara",
        "regional_bloc": "IGAD"
    },
    {
        "country": "Eswatini",
        "capital": "Mbabane",
        "currency": "lilangeni",
        "independence_year": 1968,
        "official_languages": ["anglais", "swati"],
        "largest_city": "Mbabane",
        "regional_bloc": "SADC"
    },
    {
        "country": "Éthiopie",
        "capital": "Addis-Abeba",
        "currency": "birr éthiopien",
        "independence_year": 1941,
        "official_languages": ["amharique"],
        "largest_city": "Addis-Abeba",
        "regional_bloc": "IGAD"
    },
    {
        "country": "Gabon",
        "capital": "Libreville",
        "currency": "franc CFA BEAC",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Libreville",
        "regional_bloc": "CEEAC"
    },
    {
        "country": "Gambie",
        "capital": "Banjul",
        "currency": "dalasi gambien",
        "independence_year": 1965,
        "official_languages": ["anglais"],
        "largest_city": "Serrekunda",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Ghana",
        "capital": "Accra",
        "currency": "cedi ghanéen",
        "independence_year": 1957,
        "official_languages": ["anglais"],
        "largest_city": "Accra",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Guinée",
        "capital": "Conakry",
        "currency": "franc guinéen",
        "independence_year": 1958,
        "official_languages": ["français"],
        "largest_city": "Conakry",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Guinée-Bissau",
        "capital": "Bissau",
        "currency": "franc CFA BCEAO",
        "independence_year": 1973,
        "official_languages": ["portugais"],
        "largest_city": "Bissau",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Guinée équatoriale",
        "capital": "Malabo",
        "currency": "franc CFA BEAC",
        "independence_year": 1968,
        "official_languages": ["espagnol", "français", "portugais"],
        "largest_city": "Bata",
        "regional_bloc": "CEEAC"
    },
    {
        "country": "Kenya",
        "capital": "Nairobi",
        "currency": "shilling kényan",
        "independence_year": 1963,
        "official_languages": ["anglais", "swahili"],
        "largest_city": "Nairobi",
        "regional_bloc": "CAE"
    },
    {
        "country": "Lesotho",
        "capital": "Maseru",
        "currency": "loti",
        "independence_year": 1966,
        "official_languages": ["anglais", "sesotho"],
        "largest_city": "Maseru",
        "regional_bloc": "SADC"
    },
    {
        "country": "Libéria",
        "capital": "Monrovia",
        "currency": "dollar libérien",
        "independence_year": 1847,
        "official_languages": ["anglais"],
        "largest_city": "Monrovia",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Libye",
        "capital": "Tripoli",
        "currency": "dinar libyen",
        "independence_year": 1951,
        "official_languages": ["arabe"],
        "largest_city": "Tripoli",
        "regional_bloc": "UMA"
    },
    {
        "country": "Madagascar",
        "capital": "Antananarivo",
        "currency": "ariary malgache",
        "independence_year": 1960,
        "official_languages": ["malgache", "français"],
        "largest_city": "Antananarivo",
        "regional_bloc": "COMESA"
    },
    {
        "country": "Malawi",
        "capital": "Lilongwe",
        "currency": "kwacha malawite",
        "independence_year": 1964,
        "official_languages": ["anglais", "chichewa"],
        "largest_city": "Lilongwe",
        "regional_bloc": "SADC"
    },
    {
        "country": "Mali",
        "capital": "Bamako",
        "currency": "franc CFA BCEAO",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Bamako",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Maroc",
        "capital": "Rabat",
        "currency": "dirham marocain",
        "independence_year": 1956,
        "official_languages": ["arabe", "tamazight"],
        "largest_city": "Casablanca",
        "regional_bloc": "UMA"
    },
    {
        "country": "Mauritanie",
        "capital": "Nouakchott",
        "currency": "ouguiya mauritanienne",
        "independence_year": 1960,
        "official_languages": ["arabe"],
        "largest_city": "Nouakchott",
        "regional_bloc": "UMA"
    },
    {
        "country": "Maurice",
        "capital": "Port-Louis",
        "currency": "roupie mauricienne",
        "independence_year": 1968,
        "official_languages": ["anglais", "français"],
        "largest_city": "Port-Louis",
        "regional_bloc": "COI"
    },
    {
        "country": "Mozambique",
        "capital": "Maputo",
        "currency": "metical mozambicain",
        "independence_year": 1975,
        "official_languages": ["portugais"],
        "largest_city": "Maputo",
        "regional_bloc": "SADC"
    },
    {
        "country": "Namibie",
        "capital": "Windhoek",
        "currency": "dollar namibien",
        "independence_year": 1990,
        "official_languages": ["anglais"],
        "largest_city": "Windhoek",
        "regional_bloc": "SADC"
    },
    {
        "country": "Niger",
        "capital": "Niamey",
        "currency": "franc CFA BCEAO",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Niamey",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Nigeria",
        "capital": "Abuja",
        "currency": "naira nigériane",
        "independence_year": 1960,
        "official_languages": ["anglais"],
        "largest_city": "Lagos",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Ouganda",
        "capital": "Kampala",
        "currency": "shilling ougandais",
        "independence_year": 1962,
        "official_languages": ["anglais", "swahili"],
        "largest_city": "Kampala",
        "regional_bloc": "CAE"
    },
    {
        "country": "République centrafricaine",
        "capital": "Bangui",
        "currency": "franc CFA BEAC",
        "independence_year": 1960,
        "official_languages": ["français", "sango"],
        "largest_city": "Bangui",
        "regional_bloc": "CEEAC"
    },
    {
        "country": "République démocratique du Congo",
        "capital": "Kinshasa",
        "currency": "franc congolais",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Kinshasa",
        "regional_bloc": "CEEAC"
    },
    {
        "country": "Rwanda",
        "capital": "Kigali",
        "currency": "franc rwandais",
        "independence_year": 1962,
        "official_languages": ["kinyarwanda", "français", "anglais"],
        "largest_city": "Kigali",
        "regional_bloc": "CAE"
    },
    {
        "country": "République arabe sahraouie démocratique",
        "capital": "Bir Lehlou",
        "currency": "dirham sahraoui",
        "independence_year": 1976,
        "official_languages": ["arabe"],
        "largest_city": "Tifariti",
        "regional_bloc": "UMA"
    },
    {
        "country": "Sao Tomé-et-Principe",
        "capital": "São Tomé",
        "currency": "dobra santoméen",
        "independence_year": 1975,
        "official_languages": ["portugais"],
        "largest_city": "São Tomé",
        "regional_bloc": "CEEAC"
    },
    {
        "country": "Sénégal",
        "capital": "Dakar",
        "currency": "franc CFA BCEAO",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Dakar",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Seychelles",
        "capital": "Victoria",
        "currency": "roupie seychelloise",
        "independence_year": 1976,
        "official_languages": ["anglais", "français", "créole seychellois"],
        "largest_city": "Victoria",
        "regional_bloc": "COI"
    },
    {
        "country": "Sierra Leone",
        "capital": "Freetown",
        "currency": "leone",
        "independence_year": 1961,
        "official_languages": ["anglais"],
        "largest_city": "Freetown",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Somalie",
        "capital": "Mogadiscio",
        "currency": "shilling somalien",
        "independence_year": 1960,
        "official_languages": ["somali", "arabe"],
        "largest_city": "Mogadiscio",
        "regional_bloc": "IGAD"
    },
    {
        "country": "Soudan",
        "capital": "Khartoum",
        "currency": "livre soudanaise",
        "independence_year": 1956,
        "official_languages": ["arabe", "anglais"],
        "largest_city": "Khartoum",
        "regional_bloc": "COMESA"
    },
    {
        "country": "Soudan du Sud",
        "capital": "Juba",
        "currency": "livre sud-soudanaise",
        "independence_year": 2011,
        "official_languages": ["anglais"],
        "largest_city": "Juba",
        "regional_bloc": "IGAD"
    },
    {
        "country": "Tanzanie",
        "capital": "Dodoma",
        "currency": "shilling tanzanien",
        "independence_year": 1961,
        "official_languages": ["swahili", "anglais"],
        "largest_city": "Dar es Salaam",
        "regional_bloc": "CAE"
    },
    {
        "country": "Tchad",
        "capital": "N'Djamena",
        "currency": "franc CFA BEAC",
        "independence_year": 1960,
        "official_languages": ["français", "arabe"],
        "largest_city": "N'Djamena",
        "regional_bloc": "CEEAC"
    },
    {
        "country": "Togo",
        "capital": "Lomé",
        "currency": "franc CFA BCEAO",
        "independence_year": 1960,
        "official_languages": ["français"],
        "largest_city": "Lomé",
        "regional_bloc": "CEDEAO"
    },
    {
        "country": "Tunisie",
        "capital": "Tunis",
        "currency": "dinar tunisien",
        "independence_year": 1956,
        "official_languages": ["arabe"],
        "largest_city": "Tunis",
        "regional_bloc": "UMA"
    },
    {
        "country": "Zambie",
        "capital": "Lusaka",
        "currency": "kwacha zambien",
        "independence_year": 1964,
        "official_languages": ["anglais"],
        "largest_city": "Lusaka",
        "regional_bloc": "SADC"
    },
    {
        "country": "Zimbabwe",
        "capital": "Harare",
        "currency": "dollar zimbabwéen",
        "independence_year": 1980,
        "official_languages": ["anglais", "shona", "ndebele"],
        "largest_city": "Harare",
        "regional_bloc": "SADC"
    }
]

# Additional specific Côte d'Ivoire facts
cote_divoire_facts = [
    {
        "key": "independence",
        "prompt": "Quelle est l'année d'indépendance de la Côte d’Ivoire ?",
        "answer": "1960",
        "choices": ["1958", "1960", "1965", "1970"],
        "explanation": "La Côte d’Ivoire est devenue indépendante de la France le 7 août 1960.",
        "difficulty": 1
    },
    {
        "key": "capital",
        "prompt": "Quelle ville est la capitale politique de la Côte d’Ivoire ?",
        "answer": "Yamoussoukro",
        "choices": ["Abidjan", "Bouaké", "Yamoussoukro", "San-Pédro"],
        "explanation": "La capitale politique est Yamoussoukro tandis qu'Abidjan est la capitale économique.",
        "difficulty": 1
    },
    {
        "key": "economic_capital",
        "prompt": "Quelle ville est reconnue comme capitale économique de la Côte d’Ivoire ?",
        "answer": "Abidjan",
        "choices": ["Yamoussoukro", "Abidjan", "Korhogo", "Man"],
        "explanation": "Abidjan concentre l'activité économique et portuaire du pays.",
        "difficulty": 1
    },
    {
        "key": "president",
        "prompt": "Qui est le président de la République de Côte d’Ivoire en 2024 ?",
        "answer": "Alassane Ouattara",
        "choices": ["Laurent Gbagbo", "Alassane Ouattara", "Henri Konan Bédié", "Robert Beugré Mambé"],
        "explanation": "Alassane Ouattara exerce la présidence de la République depuis 2011.",
        "difficulty": 1
    },
    {
        "key": "prime_minister",
        "prompt": "Qui occupe la fonction de Premier ministre de Côte d’Ivoire depuis octobre 2023 ?",
        "answer": "Robert Beugré Mambé",
        "choices": ["Patrick Achi", "Amadou Gon Coulibaly", "Robert Beugré Mambé", "Tiémoko Meyliet Koné"],
        "explanation": "Robert Beugré Mambé a été nommé Premier ministre en octobre 2023.",
        "difficulty": 1
    },
    {
        "key": "vice_president",
        "prompt": "Quel est le nom du vice-président de la Côte d’Ivoire nommé en 2022 ?",
        "answer": "Tiémoko Meyliet Koné",
        "choices": ["Daniel Kablan Duncan", "Tiémoko Meyliet Koné", "Kouadio Konan Bertin", "Ahmed Bakayoko"],
        "explanation": "Tiémoko Meyliet Koné a été nommé vice-président en avril 2022.",
        "difficulty": 1
    },
    {
        "key": "population",
        "prompt": "Quelle population a été recensée en Côte d’Ivoire lors du RGPH 2021 ?",
        "answer": "29,4 millions d'habitants",
        "choices": ["24,2 millions", "26,8 millions", "29,4 millions d'habitants", "32,1 millions"],
        "explanation": "Le Recensement Général de la Population et de l'Habitat 2021 a comptabilisé 29 389 150 habitants.",
        "difficulty": 2
    },
    {
        "key": "currency",
        "prompt": "Quelle monnaie est utilisée en Côte d’Ivoire ?",
        "answer": "Franc CFA (XOF)",
        "choices": ["Naira", "Franc CFA (XOF)", "Cedi", "Dollar libérien"],
        "explanation": "La Côte d’Ivoire utilise le franc CFA de l'UEMOA, émis par la BCEAO.",
        "difficulty": 1
    },
    {
        "key": "main_export",
        "prompt": "Quel produit figure parmi les principales exportations de la Côte d’Ivoire en 2023 ?",
        "answer": "Cacao",
        "choices": ["Coton", "Cacao", "Thé", "Riz"],
        "explanation": "La Côte d’Ivoire est le premier producteur mondial de cacao et en exporte massivement.",
        "difficulty": 1
    },
    {
        "key": "port",
        "prompt": "Quel port ivoirien concentre la majorité du trafic maritime national ?",
        "answer": "Port d’Abidjan",
        "choices": ["Port de San-Pédro", "Port de Sassandra", "Port d’Abidjan", "Port de Grand-Bassam"],
        "explanation": "Le port d'Abidjan est la principale plateforme portuaire d'Afrique de l'Ouest.",
        "difficulty": 2
    },
    {
        "key": "pnd",
        "prompt": "Quel plan national de développement couvre la période 2021-2025 ?",
        "answer": "PND 2021-2025",
        "choices": ["PND 2012-2015", "PND 2016-2020", "PND 2021-2025", "PND 2026-2030"],
        "explanation": "Le Plan National de Développement 2021-2025 structure la stratégie économique actuelle.",
        "difficulty": 2
    },
    {
        "key": "districts",
        "prompt": "Combien de districts compte la Côte d’Ivoire (y compris les districts autonomes) ?",
        "answer": "14",
        "choices": ["10", "12", "14", "16"],
        "explanation": "La réforme de 2011 a porté à 14 le nombre de districts, dont Abidjan et Yamoussoukro autonomes.",
        "difficulty": 2
    },
    {
        "key": "regions",
        "prompt": "Combien de régions administratives composent la Côte d’Ivoire depuis 2011 ?",
        "answer": "31",
        "choices": ["24", "28", "31", "33"],
        "explanation": "La Côte d’Ivoire est organisée en 31 régions administratives depuis la réforme territoriale de 2011.",
        "difficulty": 2
    },
    {
        "key": "constitution",
        "prompt": "Quelle année marque l’adoption de la Constitution de la Troisième République ivoirienne ?",
        "answer": "2016",
        "choices": ["2000", "2010", "2016", "2020"],
        "explanation": "La Constitution de la Troisième République a été adoptée par référendum le 30 octobre 2016.",
        "difficulty": 2
    },
    {
        "key": "revision_constitution",
        "prompt": "En quelle année la Constitution ivoirienne a-t-elle été révisée pour clarifier le rôle du vice-président ?",
        "answer": "2020",
        "choices": ["2018", "2019", "2020", "2022"],
        "explanation": "La révision du 19 mars 2020 a précisé les modalités de succession et le statut du vice-président.",
        "difficulty": 2
    },
    {
        "key": "bceao",
        "prompt": "Quel institut régional émet la monnaie utilisée en Côte d’Ivoire ?",
        "answer": "BCEAO",
        "choices": ["BEAC", "BCEAO", "BAD", "BIRD"],
        "explanation": "La Banque Centrale des États de l’Afrique de l’Ouest (BCEAO) émet le franc CFA utilisé en Côte d’Ivoire.",
        "difficulty": 1
    },
    {
        "key": "rgph",
        "prompt": "Quel organisme a publié les résultats du RGPH 2021 en Côte d’Ivoire ?",
        "answer": "Institut National de la Statistique",
        "choices": ["Banque mondiale", "FMI", "Institut National de la Statistique", "Commission de l’Union africaine"],
        "explanation": "L’INS est l’organisme public chargé du recensement et des statistiques officielles.",
        "difficulty": 2
    },
    {
        "key": "ports",
        "prompt": "Quel deuxième port ivoirien soutient l’exportation de cacao et de bois ?",
        "answer": "Port de San-Pédro",
        "choices": ["Port de Sassandra", "Port de Grand-Bassam", "Port de San-Pédro", "Port de Jacqueville"],
        "explanation": "Le port en eau profonde de San-Pédro est spécialisé dans l’exportation de cacao et de bois.",
        "difficulty": 2
    },
    {
        "key": "energy_mix",
        "prompt": "Quelle source contribue le plus à la production électrique ivoirienne ?",
        "answer": "Gaz naturel",
        "choices": ["Gaz naturel", "Charbon", "Énergie solaire", "Énergie éolienne"],
        "explanation": "Les centrales thermiques alimentées au gaz naturel fournissent l’essentiel de l’électricité ivoirienne.",
        "difficulty": 3
    },
    {
        "key": "transport",
        "prompt": "Quel ouvrage relie les quartiers de Marcory et Treichville à Abidjan ?",
        "answer": "Pont Henri-Konané Bédié",
        "choices": ["Pont Félix Houphouët-Boigny", "Pont Général de Gaulle", "Pont Henri-Konané Bédié", "Pont Charles de Gaulle"],
        "explanation": "Le pont Henri-Konané Bédié, inauguré en 2014, fluidifie le trafic entre Marcory et Treichville.",
        "difficulty": 3
    },
    {
        "key": "river",
        "prompt": "Quel est le plus long fleuve de la Côte d’Ivoire ?",
        "answer": "Bandama",
        "choices": ["Comoé", "Bandama", "Sassandra", "Cavally"],
        "explanation": "Le fleuve Bandama traverse le pays du nord au sud sur plus de 800 km.",
        "difficulty": 1
    },
    {
        "key": "highest_point",
        "prompt": "Quel massif abrite le point culminant de la Côte d’Ivoire ?",
        "answer": "Mont Nimba",
        "choices": ["Mont Péko", "Mont Nimba", "Mont Tonkoui", "Mont Sangbé"],
        "explanation": "Le mont Nimba, à 1 752 m, est partagé avec la Guinée et le Liberia et constitue le point culminant national.",
        "difficulty": 2
    },
    {
        "key": "unesco",
        "prompt": "Quel parc national ivoirien est inscrit au patrimoine mondial de l’UNESCO pour sa biodiversité tropicale ?",
        "answer": "Parc national de Taï",
        "choices": ["Parc national du Banco", "Parc national d’Azagny", "Parc national de Taï", "Parc national de la Comoé"],
        "explanation": "Le parc national de Taï abrite l’une des dernières forêts primaires d’Afrique de l’Ouest.",
        "difficulty": 2
    },
    {
        "key": "airport",
        "prompt": "Quel est l’aéroport international principal de la Côte d’Ivoire ?",
        "answer": "Aéroport Félix Houphouët-Boigny",
        "choices": ["Aéroport de Yamoussoukro", "Aéroport Félix Houphouët-Boigny", "Aéroport de Bouaké", "Aéroport de San-Pédro"],
        "explanation": "L’aéroport Félix Houphouët-Boigny d’Abidjan concentre l’essentiel du trafic aérien ivoirien.",
        "difficulty": 1
    },
    {
        "key": "lagoon",
        "prompt": "Quel plan d’eau borde la ville d’Abidjan ?",
        "answer": "Lagune Ébrié",
        "choices": ["Lagune Aby", "Lagune Ébrié", "Lagune Aghien", "Lagune Fresco"],
        "explanation": "La lagune Ébrié sépare les différentes communes d’Abidjan et abrite le port lagunaire.",
        "difficulty": 1
    },
    {
        "key": "dam",
        "prompt": "Quel barrage hydroélectrique, mis en service en 2017, renforce la capacité énergétique ivoirienne ?",
        "answer": "Barrage de Soubré",
        "choices": ["Barrage de Kossou", "Barrage de Soubré", "Barrage de Buyo", "Barrage de Taabo"],
        "explanation": "Le barrage de Soubré sur la Sassandra est la plus grande centrale hydroélectrique du pays.",
        "difficulty": 2
    },
    {
        "key": "reservoir",
        "prompt": "Quel lac artificiel a été créé par le barrage de Kossou ?",
        "answer": "Lac de Kossou",
        "choices": ["Lac de Taabo", "Lac de Kossou", "Lac de Buyo", "Lac de Soubré"],
        "explanation": "Le lac de Kossou est un vaste réservoir sur le fleuve Bandama issu du barrage du même nom.",
        "difficulty": 2
    },
    {
        "key": "border_east",
        "prompt": "Quel pays partage la frontière orientale avec la Côte d’Ivoire ?",
        "answer": "Ghana",
        "choices": ["Liberia", "Ghana", "Mali", "Guinée"],
        "explanation": "La Côte d’Ivoire est bordée à l’est par le Ghana, au nord par le Mali et le Burkina Faso.",
        "difficulty": 1
    },
    {
        "key": "border_west",
        "prompt": "Quel pays longe principalement la frontière occidentale de la Côte d’Ivoire ?",
        "answer": "Libéria",
        "choices": ["Ghana", "Sénégal", "Libéria", "Gambie"],
        "explanation": "Le Libéria partage une longue frontière terrestre et forestière avec la Côte d’Ivoire à l’ouest.",
        "difficulty": 1
    },
    {
        "key": "hymn",
        "prompt": "Quel est l’hymne national de la Côte d’Ivoire ?",
        "answer": "L’Abidjanaise",
        "choices": ["L’Abidjanaise", "La Concorde", "La Teranga", "Nkosi Sikelel’ iAfrika"],
        "explanation": "L’Abidjanaise, adoptée en 1960, est l’hymne national ivoirien.",
        "difficulty": 1
    },
    {
        "key": "football_club",
        "prompt": "Quel club ivoirien détient le record de titres en Ligue 1 ?",
        "answer": "ASEC Mimosas",
        "choices": ["AFAD", "ASEC Mimosas", "Sewe Sport", "Stade d’Abidjan"],
        "explanation": "L’ASEC Mimosas est le club le plus titré du championnat de Côte d’Ivoire.",
        "difficulty": 2
    },
    {
        "key": "stadium",
        "prompt": "Quel stade de 60 000 places a accueilli la CAN 2023 en Côte d’Ivoire ?",
        "answer": "Stade Alassane Ouattara d’Ébimpé",
        "choices": ["Stade Félix Houphouët-Boigny", "Stade Alassane Ouattara d’Ébimpé", "Stade de Bouaké", "Stade de San-Pédro"],
        "explanation": "Le stade Alassane Ouattara d’Ébimpé, inauguré en 2020, a servi de stade principal de la CAN 2023.",
        "difficulty": 2
    },
    {
        "key": "education",
        "prompt": "Quelle grande école de formation administrative est basée à Abidjan-Cocody ?",
        "answer": "ENA de Côte d’Ivoire",
        "choices": ["INPHB", "ENA de Côte d’Ivoire", "ESATIC", "ESCA"],
        "explanation": "L’École Nationale d’Administration (ENA) forme les hauts fonctionnaires ivoiriens.",
        "difficulty": 2
    },
    {
        "key": "economic_zone",
        "prompt": "Quel est le principal port sec et zone industrielle située à proximité d’Abidjan ?",
        "answer": "Zone industrielle de Yopougon",
        "choices": ["Zone industrielle de Vridi", "Zone industrielle de Yopougon", "Zone industrielle de Bouaké", "Zone industrielle de San-Pédro"],
        "explanation": "La zone industrielle de Yopougon regroupe de nombreuses entreprises agroalimentaires et manufacturières.",
        "difficulty": 3
    },
    {
        "key": "bank",
        "prompt": "Quelle institution financière panafricaine a son siège à Abidjan ?",
        "answer": "Banque africaine de développement",
        "choices": ["FMI", "Banque mondiale", "Banque africaine de développement", "BCEAO"],
        "explanation": "La Banque africaine de développement a son siège à Abidjan depuis 2014.",
        "difficulty": 2
    },
    {
        "key": "languages",
        "prompt": "Quelle langue joue le rôle de langue officielle et d’administration en Côte d’Ivoire ?",
        "answer": "Français",
        "choices": ["Français", "Anglais", "Baoulé", "Dioula"],
        "explanation": "Le français est la langue officielle et d’administration, utilisée dans l’enseignement et la fonction publique.",
        "difficulty": 1
    },
    {
        "key": "religion",
        "prompt": "Quelle basilique monumentale, inaugurée en 1990, se situe à Yamoussoukro ?",
        "answer": "Basilique Notre-Dame de la Paix",
        "choices": ["Basilique Saint-Pierre de Yopougon", "Basilique Notre-Dame de la Paix", "Cathédrale Saint-Paul", "Sanctuaire Marial d’Abidjan"],
        "explanation": "La basilique Notre-Dame de la Paix de Yamoussoukro est l’une des plus grandes églises du monde.",
        "difficulty": 1
    },
    {
        "key": "transport2",
        "prompt": "Quel réseau urbain de transport collectif a été inauguré en 2023 à Abidjan ?",
        "answer": "Ligne 1 du métro d’Abidjan",
        "choices": ["Ligne 1 du métro d’Abidjan", "Tramway d’Abidjan", "Téléphérique d’Abobo", "Train express d’Anyama"],
        "explanation": "La première phase du métro d’Abidjan a démarré en 2023 pour fluidifier les déplacements urbains.",
        "difficulty": 3
    },
    {
        "key": "agriculture",
        "prompt": "Quel produit agricole fait de la Côte d’Ivoire le premier fournisseur mondial ?",
        "answer": "Cacao",
        "choices": ["Café", "Cacao", "Coton", "Thé"],
        "explanation": "La Côte d’Ivoire fournit environ 40 % de la production mondiale de cacao.",
        "difficulty": 1
    },
    {
        "key": "industry",
        "prompt": "Quel site portuaire ivoirien accueille un terminal minéralier stratégique ?",
        "answer": "Port de San-Pédro",
        "choices": ["Port d’Abidjan", "Port de San-Pédro", "Port de Grand-Bassam", "Port de Sassandra"],
        "explanation": "Le port de San-Pédro dispose d’un terminal minéralier pour le manganèse et le nickel.",
        "difficulty": 2
    },
    {
        "key": "culture",
        "prompt": "Quel festival d’art et de culture se tient annuellement à Abidjan depuis 1993 ?",
        "answer": "MASA",
        "choices": ["FESPACO", "MASA", "Festival de Cannes", "Mawlid"],
        "explanation": "Le Marché des Arts du Spectacle Africain (MASA) rassemble artistes et professionnels à Abidjan.",
        "difficulty": 2
    }
]

ua_facts = [
    {
        "key": "creation",
        "prompt": "En quelle année l’Union africaine a-t-elle été lancée pour succéder à l’OUA ?",
        "answer": "2002",
        "choices": ["1999", "2000", "2001", "2002"],
        "explanation": "L’Union africaine est officiellement lancée au sommet de Durban en juillet 2002.",
        "difficulty": 2
    },
    {
        "key": "oua_creation",
        "prompt": "Quelle année marque la création de l’Organisation de l’unité africaine (OUA) ?",
        "answer": "1963",
        "choices": ["1958", "1960", "1963", "1965"],
        "explanation": "L’OUA a été créée le 25 mai 1963 à Addis-Abeba pour promouvoir l’unité et la solidarité africaines.",
        "difficulty": 2
    },
    {
        "key": "seat",
        "prompt": "Où se situe le siège de l’Union africaine ?",
        "answer": "Addis-Abeba",
        "choices": ["Accra", "Addis-Abeba", "Johannesburg", "Nairobi"],
        "explanation": "Le siège de l’Union africaine est établi à Addis-Abeba en Éthiopie.",
        "difficulty": 1
    },
    {
        "key": "chairperson",
        "prompt": "Quelle institution dirige l’administration de l’Union africaine au quotidien ?",
        "answer": "Commission de l’Union africaine",
        "choices": ["Conseil exécutif", "Commission de l’Union africaine", "Parlement panafricain", "Cour africaine"],
        "explanation": "La Commission de l’Union africaine est l’organe exécutif chargé de la gestion quotidienne.",
        "difficulty": 2
    },
    {
        "key": "assembly",
        "prompt": "Quel organe réunit les chefs d’État et de gouvernement des États membres de l’Union africaine ?",
        "answer": "Assemblée de l’Union",
        "choices": ["Conseil exécutif", "Comité des représentants permanents", "Assemblée de l’Union", "Parlement panafricain"],
        "explanation": "L’Assemblée de l’Union rassemble les chefs d’État et de gouvernement une fois par an.",
        "difficulty": 2
    },
    {
        "key": "cps",
        "prompt": "Quel organe de l’Union africaine veille à la paix et à la sécurité collectives ?",
        "answer": "Conseil de paix et de sécurité",
        "choices": ["Comité des représentants permanents", "Conseil de paix et de sécurité", "Comité technique spécialisé", "Fonds africain de développement"],
        "explanation": "Le Conseil de paix et de sécurité (CPS) traite des conflits et crises sur le continent.",
        "difficulty": 2
    },
    {
        "key": "agenda2063",
        "prompt": "Quel document stratégique fixe les aspirations de l’Union africaine à l’horizon 2063 ?",
        "answer": "Agenda 2063",
        "choices": ["Agenda 2030", "Compact 2050", "Agenda 2063", "Vision 2025"],
        "explanation": "Agenda 2063 exprime la vision d'une Afrique intégrée, prospère et pacifique.",
        "difficulty": 2
    },
    {
        "key": "afcfta",
        "prompt": "Comment se nomme la zone de libre-échange continentale pilotée par l’Union africaine ?",
        "answer": "ZLECAf",
        "choices": ["CEDEAO", "ZLECAf", "COMESA", "SADC"],
        "explanation": "La Zone de libre-échange continentale africaine (ZLECAf) est un projet phare de l’Agenda 2063.",
        "difficulty": 2
    },
    {
        "key": "financial_institution",
        "prompt": "Quel groupe panafricain sert de bras financier multilatéral au service des projets continentaux ?",
        "answer": "Banque africaine de développement",
        "choices": ["BCEAO", "Banque africaine de développement", "Banque centrale européenne", "FMI"],
        "explanation": "La BAD, basée à Abidjan, finance des projets d’intégration et de développement dans les pays membres.",
        "difficulty": 2
    },
    {
        "key": "parliament",
        "prompt": "Quel organe de l’Union africaine siège à Midrand en Afrique du Sud ?",
        "answer": "Parlement panafricain",
        "choices": ["Commission", "Parlement panafricain", "Conseil exécutif", "Cour africaine"],
        "explanation": "Le Parlement panafricain siège à Midrand et représente les peuples africains.",
        "difficulty": 2
    },
    {
        "key": "court",
        "prompt": "Quel organe judiciaire régional est chargé de veiller au respect des droits de l’homme et des peuples ?",
        "answer": "Cour africaine des droits de l’homme et des peuples",
        "choices": ["Commission africaine des droits de l’homme", "Cour africaine des droits de l’homme et des peuples", "Comité des représentants permanents", "CPS"],
        "explanation": "La Cour africaine, basée à Arusha, complète la Commission africaine pour protéger les droits humains.",
        "difficulty": 3
    },
    {
        "key": "peace_fund",
        "prompt": "Quel instrument financier soutient les opérations de paix de l’Union africaine ?",
        "answer": "Fonds pour la paix",
        "choices": ["Fonds pour le climat", "Fonds pour la paix", "Fonds routier panafricain", "Fonds agricole continental"],
        "explanation": "Le Fonds pour la paix finance les missions d’observation et les opérations de soutien à la paix.",
        "difficulty": 3
    },
    {
        "key": "auc_chair",
        "prompt": "Comment est désigné le président en exercice de l’Union africaine ?",
        "answer": "Par rotation annuelle entre chefs d’État",
        "choices": ["Par vote populaire", "Par rotation annuelle entre chefs d’État", "Par nomination de la Commission", "Par tirage au sort"],
        "explanation": "La présidence tournante de l’UA est assumée chaque année par un chef d’État ou de gouvernement membre.",
        "difficulty": 2
    },
    {
        "key": "psc_members",
        "prompt": "Combien de membres siège au Conseil de paix et de sécurité de l’Union africaine ?",
        "answer": "15",
        "choices": ["10", "12", "15", "20"],
        "explanation": "Le CPS compte 15 membres élus par l’Assemblée de l’Union pour des mandats de deux ou trois ans.",
        "difficulty": 3
    },
    {
        "key": "languages",
        "prompt": "Quelles sont les langues de travail de l’Union africaine ?",
        "answer": "Arabe, anglais, espagnol, français, portugais et swahili",
        "choices": [
            "Arabe et anglais",
            "Arabe, anglais, espagnol, français, portugais et swahili",
            "Anglais, français et portugais seulement",
            "Français, swahili et amharique"
        ],
        "explanation": "L’UA reconnaît six langues de travail depuis l’ajout du swahili en 2022.",
        "difficulty": 3
    },
    {
        "key": "aec",
        "prompt": "Quel traité fondateur de 1991 vise la création de la Communauté économique africaine ?",
        "answer": "Traité d’Abuja",
        "choices": ["Traité de Lagos", "Traité du Cap", "Traité d’Abuja", "Traité de Maputo"],
        "explanation": "Le traité d’Abuja de 1991 jette les bases d’une Communauté économique africaine en six phases.",
        "difficulty": 3
    },
    {
        "key": "peace_support",
        "prompt": "Quel mécanisme prépare des brigades régionales pour des opérations de paix rapides ?",
        "answer": "Force africaine en attente",
        "choices": ["Force panafricaine navale", "Force africaine en attente", "Brigade de l’océan Indien", "Mission d’observation du Nil"],
        "explanation": "La Force africaine en attente est un dispositif régionalisé capable de déploiements rapides.",
        "difficulty": 3
    },
    {
        "key": "nepad",
        "prompt": "Quel programme de l’Union africaine vise l’accélération du développement socio-économique ?",
        "answer": "NEPAD",
        "choices": ["NEPAD", "PIDA", "AMV", "CAADP"],
        "explanation": "Le Nouveau partenariat pour le développement de l’Afrique (NEPAD) est intégré à l’UA depuis 2018.",
        "difficulty": 3
    },
    {
        "key": "pida",
        "prompt": "Quel cadre priorise les infrastructures régionales dans le cadre de l’Agenda 2063 ?",
        "answer": "Programme de développement des infrastructures en Afrique",
        "choices": ["Programme de développement agricole", "Programme de développement des infrastructures en Afrique", "Programme santé Afrique", "Plan continental énergie"],
        "explanation": "Le PIDA coordonne les grands projets énergétiques, routiers et numériques continentaux.",
        "difficulty": 3
    }
]

# Generate questions
questions = []

existing_ids = set()

start_index = 1151

# Helper functions

def add_question(question):
    qid = question["id"]
    if qid in existing_ids:
        raise ValueError(f"Duplicate id: {qid}")
    existing_ids.add(qid)
    questions.append(question)

# Generate from capitals, currencies etc

def make_choices(correct, pool, count=3):
    distractors = random.sample([item for item in pool if item != correct], count)
    return distractors

# Flatten data for use
capitals_pool = [c["capital"] for c in countries]
country_pool = [c["country"] for c in countries]
currencies_pool = [c["currency"] for c in countries]
independence_years_pool = [str(c["independence_year"]) for c in countries]

# Variation generating functions

def generate_capital_questions():
    global start_index
    for entry in countries:
        country = entry["country"]
        capital = entry["capital"]
        # Variation 1
        choices = make_choices(capital, capitals_pool)
        all_choices = choices + [capital]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 1,
            "question": f"Quelle est la capitale du pays nommé {country} ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(capital),
            "explanation": f"Le pays {country} a pour capitale {capital}.",
        })
        start_index += 1
        # Variation 2
        choices = make_choices(country, country_pool)
        all_choices = choices + [country]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 1,
            "question": f"Dans quel pays africain se situe la capitale {capital} ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(country),
            "explanation": f"La ville de {capital} est la capitale du pays {country}.",
        })
        start_index += 1
        # Variation 3
        alt_capital = random.choice([c for c in capitals_pool if c != capital])
        alt_country = random.choice([c for c in country_pool if c != country])
        options = [
            f"{country} – {capital}",
            f"{country} – {alt_capital}",
            f"{alt_country} – {capital}",
            f"{alt_country} – {alt_capital}",
        ]
        random.shuffle(options)
        correct_option = f"{country} – {capital}"
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 2,
            "question": f"Quel duo pays-capitale correspond au pays {country} ?",
            "choices": options,
            "answerIndex": options.index(correct_option),
            "explanation": f"{country} a pour capitale {capital}.",
        })
        start_index += 1
        # Variation 4 (siège du gouvernement lorsqu'il diffère)
        seat = entry.get("seat_of_government", capital)
        if seat:
            seat_choices = make_choices(seat, capitals_pool)
            all_choices = seat_choices + [seat]
            random.shuffle(all_choices)
            wording = "Quelle ville abrite le siège du gouvernement de {country} ?" if seat != capital else "Quelle ville concentre les institutions nationales de {country} ?"
            add_question({
                "id": f"CG-AF-{start_index:04d}",
                "concours": "ENA",
                "subject": "Culture Générale",
                "chapter": "Afrique",
                "difficulty": 2,
                "question": wording.format(country=country),
                "choices": all_choices,
                "answerIndex": all_choices.index(seat),
                "explanation": f"La ville de {seat} accueille les principales institutions nationales de {country}.",
            })
            start_index += 1


def generate_currency_questions():
    global start_index
    for entry in countries:
        country = entry["country"]
        currency = entry["currency"]
        choices = make_choices(currency, currencies_pool)
        all_choices = choices + [currency]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 2,
            "question": f"Quelle monnaie a cours légal en {country} ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(currency),
            "explanation": f"La monnaie utilisée en {country} est le {currency}.",
        })
        start_index += 1
        choices = make_choices(country, country_pool)
        all_choices = choices + [country]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 2,
            "question": f"Le {currency} est la devise de quel pays africain ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(country),
            "explanation": f"Le {currency} est utilisé en {country}.",
        })
        start_index += 1
        # Variation 3 : pays partageant la même monnaie
        peers = [c["country"] for c in countries if c["currency"] == currency and c["country"] != country]
        if peers:
            peer = random.choice(peers)
            other_country = random.choice([c for c in country_pool if c not in (country, peer)])
            options = [
                f"{country} et {peer}",
                f"{country} et {other_country}",
                f"{peer} et {other_country}",
                f"{other_country} et {peer}",
            ]
            random.shuffle(options)
            correct = f"{country} et {peer}"
            add_question({
                "id": f"CG-AF-{start_index:04d}",
                "concours": "ENA",
                "subject": "Culture Générale",
                "chapter": "Afrique",
                "difficulty": 3,
                "question": f"Quelle association regroupe deux pays utilisant le {currency} ?",
                "choices": options,
                "answerIndex": options.index(correct),
                "explanation": f"{country} et {peer} utilisent tous deux le {currency}.",
            })
            start_index += 1


def generate_independence_questions():
    global start_index
    for entry in countries:
        country = entry["country"]
        year = str(entry["independence_year"])
        choices = make_choices(year, independence_years_pool)
        all_choices = choices + [year]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 2,
            "question": f"Quelle est l’année d’indépendance du pays {country} ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(year),
            "explanation": f"{country} est devenu indépendant en {year}.",
        })
        start_index += 1
        choices = make_choices(country, country_pool)
        all_choices = choices + [country]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 2,
            "question": f"Quel pays africain a accédé à l’indépendance en {year} ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(country),
            "explanation": f"{country} a proclamé son indépendance en {year}.",
        })
        start_index += 1
        # Variation 3 : comparaison chronologique
        other = random.choice([c for c in countries if c["country"] != country])
        other_name = other["country"]
        other_year = other["independence_year"]
        if other_year != entry["independence_year"]:
            options = [country, other_name]
            options.extend(random.sample([c for c in country_pool if c not in (country, other_name)], 2))
            random.shuffle(options)
            if other_year < entry["independence_year"]:
                correct_name = other_name
                explanation = f"{other_name} ({other_year}) a accédé à l’indépendance avant {country} ({year})."
            else:
                correct_name = country
                explanation = f"{country} ({year}) a obtenu son indépendance avant {other_name} ({other_year})."
            add_question({
                "id": f"CG-AF-{start_index:04d}",
                "concours": "ENA",
                "subject": "Culture Générale",
                "chapter": "Afrique",
                "difficulty": 3,
                "question": f"Quel pays a obtenu son indépendance en premier entre {country} et {other_name} ?",
                "choices": options,
                "answerIndex": options.index(correct_name),
                "explanation": explanation,
            })
            start_index += 1


def generate_language_questions():
    global start_index
    for entry in countries:
        country = entry["country"]
        languages = entry.get("official_languages", [])
        if not languages:
            continue
        correct = random.choice(languages)
        pool = set(l for c in countries for l in c.get("official_languages", []))
        choices = make_choices(correct, list(pool))
        all_choices = choices + [correct]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 3,
            "question": f"Laquelle de ces langues a statut officiel en {country} ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(correct),
            "explanation": f"La {correct} fait partie des langues officielles reconnues en {country}.",
        })
        start_index += 1
        # Variation 2 : pays correspondant à la langue
        language_country_pool = [
            (c["country"], lang)
            for c in countries
            for lang in c.get("official_languages", [])
        ]
        same_language_countries = [c for c, lang in language_country_pool if lang == correct]
        if same_language_countries:
            choices_countries = make_choices(country, country_pool)
            all_country_choices = choices_countries + [country]
            random.shuffle(all_country_choices)
            add_question({
                "id": f"CG-AF-{start_index:04d}",
                "concours": "ENA",
                "subject": "Culture Générale",
                "chapter": "Afrique",
                "difficulty": 3,
                "question": f"Dans quel pays africain la langue {correct} a-t-elle un statut officiel ?",
                "choices": all_country_choices,
                "answerIndex": all_country_choices.index(country),
                "explanation": f"La {correct} est reconnue officiellement en {country}.",
            })
            start_index += 1
        # Variation 3 : couple pays-langue
        alt_country = random.choice([c for c in country_pool if c != country])
        alt_language = random.choice(list(pool - {correct}))
        combos = [
            f"{country} – {correct}",
            f"{country} – {alt_language}",
            f"{alt_country} – {correct}",
            f"{alt_country} – {alt_language}",
        ]
        random.shuffle(combos)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 3,
            "question": f"Quel duo pays-langue officielle est correct pour {country} ?",
            "choices": combos,
            "answerIndex": combos.index(f"{country} – {correct}"),
            "explanation": f"{country} reconnaît officiellement la {correct}.",
        })
        start_index += 1


def generate_bloc_questions():
    global start_index
    blocs = sorted(set(c.get("regional_bloc", "") for c in countries if c.get("regional_bloc")))
    for entry in countries:
        country = entry["country"]
        bloc = entry.get("regional_bloc")
        if not bloc:
            continue
        choices = make_choices(bloc, blocs)
        all_choices = choices + [bloc]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 3,
            "question": f"À quelle organisation régionale est associé {country} ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(bloc),
            "explanation": f"{country} est membre de {bloc} au sein des communautés économiques régionales reconnues par l’UA.",
        })
        start_index += 1
        # Variation 2 : pays membre du même bloc
        bloc_members = [c["country"] for c in countries if c.get("regional_bloc") == bloc]
        if len(bloc_members) > 1:
            peer = random.choice([m for m in bloc_members if m != country])
            distractors = random.sample([c for c in country_pool if c not in bloc_members], 3)
            options = distractors + [peer]
            random.shuffle(options)
            add_question({
                "id": f"CG-AF-{start_index:04d}",
                "concours": "ENA",
                "subject": "Culture Générale",
                "chapter": "Afrique",
                "difficulty": 3,
                "question": f"Lequel de ces pays appartient également à {bloc} ?",
                "choices": options,
                "answerIndex": options.index(peer),
                "explanation": f"{peer} fait partie, comme {country}, de {bloc}.",
            })
            start_index += 1


def generate_largest_city_questions():
    global start_index
    largest_pool = [c.get("largest_city", c["capital"]) for c in countries]
    for entry in countries:
        country = entry["country"]
        largest = entry.get("largest_city", entry["capital"])
        choices = make_choices(largest, largest_pool)
        all_choices = choices + [largest]
        random.shuffle(all_choices)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 2,
            "question": f"Quelle ville est la plus peuplée du pays {country} ?",
            "choices": all_choices,
            "answerIndex": all_choices.index(largest),
            "explanation": f"La ville de {largest} est la plus grande agglomération du pays {country}.",
        })
        start_index += 1
        # Variation 2 : rattachement de la métropole
        choices_country = make_choices(country, country_pool)
        options_country = choices_country + [country]
        random.shuffle(options_country)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 2,
            "question": f"Dans quel pays africain se situe la ville de {largest} ?",
            "choices": options_country,
            "answerIndex": options_country.index(country),
            "explanation": f"La ville de {largest} se situe en {country}.",
        })
        start_index += 1
        # Variation 3 : association pays-ville principale
        alt_country = random.choice([c for c in country_pool if c != country])
        alt_city = random.choice([c for c in largest_pool if c != largest])
        combos = [
            f"{country} – {largest}",
            f"{country} – {alt_city}",
            f"{alt_country} – {largest}",
            f"{alt_country} – {alt_city}",
        ]
        random.shuffle(combos)
        add_question({
            "id": f"CG-AF-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Afrique",
            "difficulty": 2,
            "question": f"Quel duo pays-ville principale est exact pour le pays {country} ?",
            "choices": combos,
            "answerIndex": combos.index(f"{country} – {largest}"),
            "explanation": f"{largest} est la ville la plus peuplée de {country}.",
        })
        start_index += 1


def generate_cote_divoire_questions():
    global start_index
    for fact in cote_divoire_facts:
        add_question({
            "id": f"CG-CI-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Côte d’Ivoire",
            "difficulty": fact["difficulty"],
            "question": fact["prompt"],
            "choices": fact["choices"],
            "answerIndex": fact["choices"].index(fact["answer"]),
            "explanation": fact["explanation"],
        })
        start_index += 1


def generate_ua_questions():
    global start_index
    for fact in ua_facts:
        add_question({
            "id": f"CG-UA-{start_index:04d}",
            "concours": "ENA",
            "subject": "Culture Générale",
            "chapter": "Union africaine",
            "difficulty": fact["difficulty"],
            "question": fact["prompt"],
            "choices": fact["choices"],
            "answerIndex": fact["choices"].index(fact["answer"]),
            "explanation": fact["explanation"],
        })
        start_index += 1


# Generate all sets

generate_capital_questions()
generate_currency_questions()
generate_independence_questions()
generate_language_questions()
generate_bloc_questions()
generate_largest_city_questions()
generate_cote_divoire_questions()
generate_ua_questions()

if len(questions) > 1000:
    questions = questions[:1000]

print(f"Generated {len(questions)} questions")

output_path = Path("CIVEXAM/assets/questions/culture_generale_afrique_ci_ua_generated.json")
output_path.write_text(json.dumps(questions, ensure_ascii=False, indent=2))
