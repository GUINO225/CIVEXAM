import 'package:flutter/material.dart';
import '../data/ena_taxonomy.dart';
import 'chapter_list_screen.dart';

/// Liste des matières ENA
/// Ajout : [subjectIndex] optionnel pour compatibilité avec les anciens appels
/// (ex: SubjectListScreen(subjectIndex: index)).
class SubjectListScreen extends StatelessWidget {
  final int? subjectIndex;
  const SubjectListScreen({super.key, this.subjectIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modules ENA')),
      body: ListView.builder(
        itemCount: subjectsENA.length,
        itemBuilder: (context, index) {
          final subject = subjectsENA[index];
          return ListTile(
            title: Text(subject.name),
            subtitle: Text('${subject.chapters.length} chapitres'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers la liste/écran de chapitres pour cette matière
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChapterListScreen(
                    subjectName: subject.name,
                    // Par défaut : premier chapitre ; l'écran de chapitres peut ignorer ce champ
                    chapterName: subject.chapters.isNotEmpty ? subject.chapters.first.name : '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
