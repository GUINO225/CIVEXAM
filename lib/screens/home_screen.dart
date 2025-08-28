import 'package:flutter/material.dart';
import '../data/ena_taxonomy.dart';
import 'subject_list_screen.dart';
import '../widgets/glass_card.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5C6BB7), Color(0xFF6C7BD0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    Text('CivExam – ENA',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      tooltip: 'Historique',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                      },
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.school, size: 56, color: Colors.black87),
                        SizedBox(height: 8),
                        Text('Préparation ENA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Choisissez une matière pour commencer vos révisions.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: subjectsENA.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = subjectsENA[index];
                      return GlassCard(
                        child: ListTile(
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => SubjectListScreen(subjectIndex: index),
                            ));
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
