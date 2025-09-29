import 'package:flutter/material.dart';

import '../data/ena_taxonomy.dart';
import '../services/question_loader.dart';
import '../widgets/play_themed_scaffold.dart';
import 'chapter_list_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  bool _loading = true;
  String? _error;
  List<Subject> _subjects = const <Subject>[];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await QuestionLoader.loadENA();
      if (!mounted) return;
      setState(() {
        _subjects = subjectsENA;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openChapter(String subjectName, String chapterName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterListScreen(
          subjectName: subjectName,
          chapterName: chapterName,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Une erreur est survenue.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSubjects,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildError();
    }
    if (_subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 48),
            const SizedBox(height: 16),
            const Text('Aucune matière disponible pour le moment.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubjects,
              child: const Text('Actualiser'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubjects,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          return Card(
            elevation: 3,
            child: ExpansionTile(
              title: Text(
                subject.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              children: [
                for (final chapter in subject.chapters)
                  ListTile(
                    title: Text(chapter.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openChapter(subject.name, chapter.name),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlayThemedScaffold(
      appBar: AppBar(title: const Text('Choisir une matière')),
      bodyMode: PlayThemedScaffoldBodyMode.panel,
      panelHeightFactor: 0.92,
      body: _buildBody(),
    );
  }
}
