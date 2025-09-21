import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modélise une section du cours de droit public.
class DroitPublicSection {
  final String title;
  final String description;
  final List<String> highlights;

  const DroitPublicSection({
    required this.title,
    required this.description,
    required this.highlights,
  });

  factory DroitPublicSection.fromJson(Map<String, dynamic> json) {
    final highlights = json['highlights'];
    return DroitPublicSection(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      highlights: highlights is List
          ? highlights.whereType<String>().toList()
          : const <String>[],
    );
  }
}

/// Chargement des sections depuis l'asset local.
class DroitPublicRepository {
  const DroitPublicRepository();

  static const String assetPath =
      'assets/courses/droit_public_constit_admin.json';

  Future<List<DroitPublicSection>> loadSections() async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final dynamic data = json.decode(jsonStr);
    if (data is! Map<String, dynamic>) {
      return const <DroitPublicSection>[];
    }
    final dynamic sectionsJson = data['sections'];
    if (sectionsJson is! List) {
      return const <DroitPublicSection>[];
    }
    return sectionsJson
        .whereType<Map<String, dynamic>>()
        .map(DroitPublicSection.fromJson)
        .where((section) => section.title.isNotEmpty)
        .toList(growable: false);
  }
}

/// Écran Droit public (constitutionnel & administratif).
class DroitPublicScreen extends StatelessWidget {
  const DroitPublicScreen({
    super.key,
    this.sectionsFuture,
  });

  final Future<List<DroitPublicSection>>? sectionsFuture;

  Future<List<DroitPublicSection>> _resolveFuture() {
    return sectionsFuture ?? const DroitPublicRepository().loadSections();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Droit public (Constitutionnel & Administratif)'),
      ),
      body: FutureBuilder<List<DroitPublicSection>>(
        future: _resolveFuture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger le contenu pour le moment.\nRéessayez plus tard.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }
          final sections = snapshot.data ?? const <DroitPublicSection>[];
          if (sections.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Aucune section disponible pour le moment.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 700;
              final EdgeInsets padding = EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: 16,
              );
              return ListView.builder(
                padding: padding,
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return Card(
                    margin: EdgeInsets.only(
                      bottom: index == sections.length - 1 ? 0 : 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 28 : 20,
                        vertical: isWide ? 28 : 20,
                      ),
                      child: _DroitPublicSectionContent(section: section),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DroitPublicSectionContent extends StatelessWidget {
  const _DroitPublicSectionContent({required this.section});

  final DroitPublicSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final bodyStyle = theme.textTheme.bodyMedium;
    final highlightStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: titleStyle),
        const SizedBox(height: 12),
        Text(section.description, style: bodyStyle),
        if (section.highlights.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Points clés',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in section.highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: highlightStyle,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
