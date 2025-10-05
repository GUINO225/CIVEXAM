import 'package:flutter/material.dart';

class ContestCalendarPhase {
  final String title;
  final String period;
  final String details;

  const ContestCalendarPhase({
    required this.title,
    required this.period,
    required this.details,
  });
}

const List<ContestCalendarPhase> _contestCalendar = <ContestCalendarPhase>[
  ContestCalendarPhase(
    title: 'Ouverture des inscriptions en ligne',
    period: '15 janvier – 29 février 2024',
    details:
        'Saisie du dossier, paiement des frais et impression du reçu sur le portail officiel (www.ena.ci).',
  ),
  ContestCalendarPhase(
    title: 'Dépôt des dossiers complets',
    period: '1er – 15 mars 2024',
    details:
        'Remise des pièces justificatives au guichet ENA d’Abidjan-Plateau ou dans les directions régionales habilitées.',
  ),
  ContestCalendarPhase(
    title: 'Publication de la liste des candidats retenus',
    period: '5 avril 2024',
    details:
        'Listes affichées au siège de l’ENA et publiées en ligne avec les convocations individuelles.',
  ),
  ContestCalendarPhase(
    title: 'Épreuves écrites d’admissibilité',
    period: '20 avril 2024 (Filière A) · 27 avril 2024 (Filières B & C)',
    details:
        'Épreuves organisées à Abidjan et dans les centres régionaux : dissertation, épreuve de spécialité et culture générale.',
  ),
  ContestCalendarPhase(
    title: 'Résultats d’admissibilité',
    period: '31 mai 2024',
    details:
        'Affichage et publication en ligne des candidats convoqués aux épreuves orales.',
  ),
  ContestCalendarPhase(
    title: 'Épreuves orales et tests psychotechniques',
    period: '10 – 21 juin 2024',
    details:
        'Entretien de motivation devant jury, test psychotechnique et vérification des dossiers pour chaque filière.',
  ),
  ContestCalendarPhase(
    title: 'Résultats définitifs',
    period: '5 juillet 2024',
    details:
        'Liste finale des admis publiée par communiqué officiel et sur le site de l’ENA.',
  ),
  ContestCalendarPhase(
    title: 'Rentrée des lauréats',
    period: '2 septembre 2024',
    details:
        'Accueil administratif, installation et démarrage de la formation initiale à l’ENA.',
  ),
];

class ContestCalendarScreen extends StatelessWidget {
  const ContestCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des concours'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _contestCalendar.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Calendrier prévisionnel ENA 2024',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Les dates ci-dessous synthétisent les jalons publiés par l’École Nationale d’Administration de Côte d’Ivoire pour la session 2024. Vérifiez régulièrement le site officiel pour toute mise à jour ou modification.',
                    ),
                  ],
                ),
              ),
            );
          }

          final phase = _contestCalendar[index - 1];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    phase.period,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phase.details,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
