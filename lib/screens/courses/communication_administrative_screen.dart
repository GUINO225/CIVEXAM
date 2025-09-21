import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modélise une section du cours de communication administrative.
class CommunicationAdministrativeSection {
  final String title;
  final String description;
  final List<String> highlights;

  const CommunicationAdministrativeSection({
    required this.title,
    required this.description,
    required this.highlights,
  });

  factory CommunicationAdministrativeSection.fromJson(
    Map<String, dynamic> json,
  ) {
    final highlights = json['highlights'];
    return CommunicationAdministrativeSection(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      highlights: highlights is List
          ? highlights.whereType<String>().toList()
          : const <String>[],
    );
  }
}

/// Chargement des sections depuis l'asset local.
class CommunicationAdministrativeRepository {
  const CommunicationAdministrativeRepository();

  static const String assetPath =
      'assets/courses/communication_administrative.json';

  Future<List<CommunicationAdministrativeSection>> loadSections() async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final dynamic data = json.decode(jsonStr);
    if (data is! Map<String, dynamic>) {
      return const <CommunicationAdministrativeSection>[];
    }
    final dynamic sectionsJson = data['sections'];
    if (sectionsJson is! List) {
      return const <CommunicationAdministrativeSection>[];
    }
    return sectionsJson
        .whereType<Map<String, dynamic>>()
        .map(CommunicationAdministrativeSection.fromJson)
        .where((section) => section.title.isNotEmpty)
        .toList(growable: false);
  }
}

/// Écran Communication administrative.
class CommunicationAdministrativeScreen extends StatelessWidget {
  const CommunicationAdministrativeScreen({
    super.key,
    this.sectionsFuture,
  });

  final Future<List<CommunicationAdministrativeSection>>? sectionsFuture;

  Future<List<CommunicationAdministrativeSection>> _resolveFuture() {
    return sectionsFuture ??
        const CommunicationAdministrativeRepository().loadSections();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication administrative'),
      ),
      body: FutureBuilder<List<CommunicationAdministrativeSection>>(
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
                  'Impossible de charger le contenu pour le moment.\n'
                  'Réessayez plus tard.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }
          final sections =
              snapshot.data ?? const <CommunicationAdministrativeSection>[];
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
                      child: _CommunicationSectionContent(section: section),
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

class _CommunicationSectionContent extends StatelessWidget {
  const _CommunicationSectionContent({required this.section});

  final CommunicationAdministrativeSection section;

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
