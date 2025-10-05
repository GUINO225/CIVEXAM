import 'package:flutter/material.dart';

enum ContestEventCategory {
  registration,
  documents,
  publication,
  writtenExam,
  oralExam,
  results,
  integration,
}

class ContestEvent {
  final DateTime date;
  final String title;
  final String description;
  final ContestEventCategory category;

  const ContestEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.category,
  });
}

final DateTime _calendarFirstDay = DateTime(2024, 1, 1);
final DateTime _calendarLastDay = DateTime(2025, 12, 31);
final DateTime _calendarStartMonth = DateTime(2024, 1, 1);
final DateTime _calendarEndMonth = DateTime(2025, 12, 1);

final List<ContestEvent> _contestEventList =
    List<ContestEvent>.unmodifiable(<ContestEvent>[
  ContestEvent(
    date: DateTime(2024, 1, 15),
    title: 'Ouverture des inscriptions en ligne',
    description:
        'L’ENA ouvre la plateforme www.ena.ci pour la saisie des dossiers et le paiement des frais d’inscription (15 janvier – 29 février 2024).',
    category: ContestEventCategory.registration,
  ),
  ContestEvent(
    date: DateTime(2024, 2, 29),
    title: 'Clôture des inscriptions',
    description:
        'Dernier jour pour valider son dossier en ligne et régler les frais de participation au concours ENA 2024.',
    category: ContestEventCategory.registration,
  ),
  ContestEvent(
    date: DateTime(2024, 3, 1),
    title: 'Dépôt des dossiers physiques',
    description:
        'Début de la remise des pièces justificatives complètes aux guichets ENA ou dans les directions régionales (1er au 15 mars 2024).',
    category: ContestEventCategory.documents,
  ),
  ContestEvent(
    date: DateTime(2024, 3, 15),
    title: 'Date limite de dépôt des dossiers',
    description:
        'Clôture de la réception des dossiers physiques pour la session 2024. Aucun document n’est accepté après cette date.',
    category: ContestEventCategory.documents,
  ),
  ContestEvent(
    date: DateTime(2024, 4, 5),
    title: 'Publication des candidats retenus',
    description:
        'Affichage des listes et des convocations sur le site officiel et au siège de l’ENA pour les épreuves écrites.',
    category: ContestEventCategory.publication,
  ),
  ContestEvent(
    date: DateTime(2024, 4, 20),
    title: 'Épreuves écrites – Filière A',
    description:
        'Organisation des épreuves d’admissibilité pour la filière A dans les centres retenus par l’ENA.',
    category: ContestEventCategory.writtenExam,
  ),
  ContestEvent(
    date: DateTime(2024, 4, 27),
    title: 'Épreuves écrites – Filières B & C',
    description:
        'Sessions écrites pour les filières B et C : dissertation, spécialité et culture générale.',
    category: ContestEventCategory.writtenExam,
  ),
  ContestEvent(
    date: DateTime(2024, 5, 31),
    title: 'Résultats d’admissibilité',
    description:
        'Publication des admissibles convoqués aux épreuves orales et aux tests psychotechniques.',
    category: ContestEventCategory.results,
  ),
  ContestEvent(
    date: DateTime(2024, 6, 10),
    title: 'Début des oraux et tests psychotechniques',
    description:
        'Entretiens devant jury et évaluations psychotechniques programmés du 10 au 21 juin 2024.',
    category: ContestEventCategory.oralExam,
  ),
  ContestEvent(
    date: DateTime(2024, 7, 5),
    title: 'Résultats définitifs',
    description: 'Proclamation officielle de la liste des admis au concours ENA 2024.',
    category: ContestEventCategory.results,
  ),
  ContestEvent(
    date: DateTime(2024, 9, 2),
    title: 'Rentrée des lauréats',
    description:
        'Accueil administratif et lancement de la formation initiale des lauréats de la session 2024.',
    category: ContestEventCategory.integration,
  ),
  ContestEvent(
    date: DateTime(2025, 1, 13),
    title: 'Ouverture des inscriptions en ligne',
    description:
        'La campagne 2025 débute avec l’activation du portail ENA pour la saisie des dossiers (13 janvier – 28 février 2025).',
    category: ContestEventCategory.registration,
  ),
  ContestEvent(
    date: DateTime(2025, 2, 28),
    title: 'Clôture des inscriptions',
    description:
        'Validation ultime des dossiers et du paiement en ligne pour participer aux concours ENA 2025.',
    category: ContestEventCategory.registration,
  ),
  ContestEvent(
    date: DateTime(2025, 3, 3),
    title: 'Début du dépôt des dossiers physiques',
    description:
        'Ouverture des guichets pour le dépôt des pièces justificatives (3 au 14 mars 2025).',
    category: ContestEventCategory.documents,
  ),
  ContestEvent(
    date: DateTime(2025, 3, 14),
    title: 'Clôture du dépôt des dossiers',
    description:
        'Fin de la période officielle de réception des dossiers de candidature pour la session 2025.',
    category: ContestEventCategory.documents,
  ),
  ContestEvent(
    date: DateTime(2025, 4, 4),
    title: 'Publication des convocations',
    description:
        'Diffusion des listes d’admissibilité aux écrits et des convocations individuelles en ligne.',
    category: ContestEventCategory.publication,
  ),
  ContestEvent(
    date: DateTime(2025, 4, 12),
    title: 'Épreuves écrites – Filière A',
    description:
        'Organisation des épreuves écrites d’admissibilité pour la filière A de la session 2025.',
    category: ContestEventCategory.writtenExam,
  ),
  ContestEvent(
    date: DateTime(2025, 4, 19),
    title: 'Épreuves écrites – Filières B & C',
    description:
        'Épreuves d’admissibilité pour les filières B et C : dissertation, spécialité et culture générale.',
    category: ContestEventCategory.writtenExam,
  ),
  ContestEvent(
    date: DateTime(2025, 5, 30),
    title: 'Résultats d’admissibilité',
    description:
        'Annonce des candidats retenus pour les entretiens oraux et évaluations psychotechniques.',
    category: ContestEventCategory.results,
  ),
  ContestEvent(
    date: DateTime(2025, 6, 9),
    title: 'Début des oraux et tests psychotechniques',
    description:
        'Période d’entretiens et d’évaluations complémentaires programmée du 9 au 20 juin 2025.',
    category: ContestEventCategory.oralExam,
  ),
  ContestEvent(
    date: DateTime(2025, 7, 4),
    title: 'Résultats définitifs',
    description: 'Publication officielle de la liste des admis au concours ENA 2025.',
    category: ContestEventCategory.results,
  ),
  ContestEvent(
    date: DateTime(2025, 9, 1),
    title: 'Rentrée des lauréats',
    description:
        'Accueil des admis 2025 et lancement du programme de formation initiale à l’ENA.',
    category: ContestEventCategory.integration,
  ),
]);

Map<DateTime, List<ContestEvent>> _buildEventIndex() {
  final Map<DateTime, List<ContestEvent>> grouped =
      <DateTime, List<ContestEvent>>{};
  for (final ContestEvent event in _contestEventList) {
    final DateTime key = DateUtils.dateOnly(event.date);
    grouped.putIfAbsent(key, () => <ContestEvent>[]).add(event);
  }
  return Map<DateTime, List<ContestEvent>>.unmodifiable(
    grouped.map(
      (DateTime key, List<ContestEvent> value) =>
          MapEntry(key, List<ContestEvent>.unmodifiable(value)),
    ),
  );
}

final Map<DateTime, List<ContestEvent>> _contestEvents = _buildEventIndex();

final List<DateTime> _orderedEventDays = List<DateTime>.unmodifiable(
  _contestEvents.keys.toList()
    ..sort((DateTime a, DateTime b) => a.compareTo(b)),
);

final Map<ContestEventCategory, String> _categoryLabels =
    <ContestEventCategory, String>{
  ContestEventCategory.registration: 'Inscriptions',
  ContestEventCategory.documents: 'Dossier physique',
  ContestEventCategory.publication: 'Convocations / publications',
  ContestEventCategory.writtenExam: 'Épreuves écrites',
  ContestEventCategory.oralExam: 'Oral & tests',
  ContestEventCategory.results: 'Résultats',
  ContestEventCategory.integration: 'Intégration',
};

class ContestCalendarScreen extends StatefulWidget {
  const ContestCalendarScreen({super.key});

  @override
  State<ContestCalendarScreen> createState() => _ContestCalendarScreenState();
}

class _ContestCalendarScreenState extends State<ContestCalendarScreen> {
  late final List<DateTime> _months;
  late final PageController _pageController;
  late DateTime _focusedMonth;
  late int _activeYear;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _months = _buildMonthList();
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    _selectedDate = _initialSelectedDate(today);
    _focusedMonth = _initialFocusedMonth(today, _selectedDate);
    _activeYear = _focusedMonth.year;
    _pageController = PageController(initialPage: _months.indexOf(_focusedMonth));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<DateTime> _buildMonthList() {
    final List<DateTime> months = <DateTime>[];
    DateTime cursor = _calendarStartMonth;
    while (!cursor.isAfter(_calendarEndMonth)) {
      months.add(cursor);
      final int year = cursor.month == 12 ? cursor.year + 1 : cursor.year;
      final int month = cursor.month == 12 ? 1 : cursor.month + 1;
      cursor = DateTime(year, month, 1);
    }
    return months;
  }

  DateTime _initialFocusedMonth(DateTime today, DateTime? selectedDate) {
    if (selectedDate != null) {
      return _months.firstWhere(
        (DateTime month) =>
            month.year == selectedDate.year && month.month == selectedDate.month,
        orElse: () => _months.first,
      );
    }
    if (_isWithinCalendar(today)) {
      return _months.firstWhere(
        (DateTime month) => month.year == today.year && month.month == today.month,
        orElse: () => _months.first,
      );
    }
    return _months.first;
  }

  DateTime? _initialSelectedDate(DateTime today) {
    if (_orderedEventDays.isEmpty) {
      return null;
    }
    if (!_isWithinCalendar(today)) {
      return _orderedEventDays.first;
    }
    for (final DateTime day in _orderedEventDays) {
      if (!day.isBefore(today)) {
        return day;
      }
    }
    return _orderedEventDays.last;
  }

  bool _isWithinCalendar(DateTime date) {
    return !date.isBefore(_calendarFirstDay) && !date.isAfter(_calendarLastDay);
  }

  List<ContestEvent> _eventsFor(DateTime day) {
    return _contestEvents[DateUtils.dateOnly(day)] ?? const <ContestEvent>[];
  }

  List<ContestEvent> _eventsForYear(int year) {
    final List<ContestEvent> events = <ContestEvent>[];
    for (final DateTime day in _orderedEventDays) {
      if (day.year != year) {
        continue;
      }
      events.addAll(_contestEvents[day] ?? const <ContestEvent>[]);
    }
    return events;
  }

  void _onDaySelected(DateTime day) {
    final List<ContestEvent> events = _eventsFor(day);
    if (events.isEmpty) {
      return;
    }
    final DateTime normalized = DateUtils.dateOnly(day);
    setState(() {
      _selectedDate = normalized;
      _activeYear = normalized.year;
    });
  }

  void _animateToMonth(int page) {
    if (page < 0 || page >= _months.length) {
      return;
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _jumpToYear(int year) {
    final int index = _months.indexWhere(
      (DateTime month) => month.year == year && month.month == 1,
    );
    if (index == -1) {
      return;
    }
    setState(() {
      _activeYear = year;
    });
    _animateToMonth(index);
  }

  Color _categoryColor(BuildContext context, ContestEventCategory category) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    switch (category) {
      case ContestEventCategory.registration:
        return scheme.primary;
      case ContestEventCategory.documents:
        return scheme.tertiary;
      case ContestEventCategory.publication:
        return scheme.secondary;
      case ContestEventCategory.writtenExam:
        return scheme.error;
      case ContestEventCategory.oralExam:
        return scheme.primaryContainer;
      case ContestEventCategory.results:
        return scheme.errorContainer;
      case ContestEventCategory.integration:
        return scheme.inversePrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final List<ContestEvent> selectedEvents =
        _selectedDate == null ? const <ContestEvent>[] : _eventsFor(_selectedDate!);
    final List<ContestEvent> timelineEvents = _eventsForYear(_activeYear);
    final int currentPage = _months.indexOf(_focusedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des concours'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Calendrier prévisionnel 2024-2025',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Repérez en un coup d’œil les principales étapes officielles du concours ENA. Les journées contenant une action sont colorées : touchez une date pour afficher le détail et consultez régulièrement le site www.ena.ci pour confirmer les informations.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Navigation par année',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      child: SegmentedButton<int>(
                        segments: const <ButtonSegment<int>>[
                          ButtonSegment<int>(value: 2024, label: Text('2024')),
                          ButtonSegment<int>(value: 2025, label: Text('2025')),
                        ],
                        selected: <int>{_activeYear},
                        onSelectionChanged: (Set<int> newSelection) {
                          if (newSelection.isEmpty) {
                            return;
                          }
                          _jumpToYear(newSelection.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 420,
                      child: Column(
                        children: <Widget>[
                          _CalendarHeader(
                            month: _focusedMonth,
                            canGoPrevious: currentPage > 0,
                            canGoNext: currentPage < _months.length - 1,
                            onNext: () => _animateToMonth(currentPage + 1),
                            onPrevious: () => _animateToMonth(currentPage - 1),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _months.length,
                              onPageChanged: (int index) {
                                setState(() {
                                  _focusedMonth = _months[index];
                                  _activeYear = _focusedMonth.year;
                                });
                              },
                              itemBuilder: (BuildContext context, int index) {
                                final DateTime month = _months[index];
                                return _MonthView(
                                  month: month,
                                  selectedDate: _selectedDate,
                                  eventsForDay: _eventsFor,
                                  categoryColor: (ContestEventCategory category) =>
                                      _categoryColor(context, category),
                                  onDaySelected: _onDaySelected,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: ContestEventCategory.values
                                .map(
                                  (ContestEventCategory category) => _LegendDot(
                                    color: _categoryColor(context, category),
                                    label: _categoryLabels[category]!,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectedDate == null
                  ? const SizedBox.shrink()
                  : _SelectedDayDetailsCard(
                      key: ValueKey<DateTime>(_selectedDate!),
                      date: _selectedDate!,
                      events: selectedEvents,
                      resolveColor: (ContestEventCategory category) =>
                          _categoryColor(context, category),
                    ),
            ),
            if (_selectedDate != null) const SizedBox(height: 24),
            if (timelineEvents.isNotEmpty)
              _YearTimelineCard(
                year: _activeYear,
                events: timelineEvents,
                resolveColor: (ContestEventCategory category) =>
                    _categoryColor(context, category),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Mois précédent',
          onPressed: canGoPrevious ? onPrevious : null,
        ),
        Expanded(
          child: Center(
            child: Text(
              localizations.formatMonthYear(month),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Mois suivant',
          onPressed: canGoNext ? onNext : null,
        ),
      ],
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.month,
    required this.selectedDate,
    required this.eventsForDay,
    required this.categoryColor,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime? selectedDate;
  final List<ContestEvent> Function(DateTime) eventsForDay;
  final Color Function(ContestEventCategory category) categoryColor;
  final ValueChanged<DateTime> onDaySelected;

  static const List<String> _weekdayLabels = <String>['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final DateTime firstDay = DateTime(month.year, month.month, 1);
    final int firstWeekday = firstDay.weekday == DateTime.sunday ? 6 : firstDay.weekday - 1;
    final int itemCount = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _weekdayLabels
              .map(
                (String label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: itemCount,
            itemBuilder: (BuildContext context, int index) {
              final int dayNumber = index - firstWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final DateTime date = DateTime(month.year, month.month, dayNumber);
              final List<ContestEvent> events = eventsForDay(date);
              final bool hasEvents = events.isNotEmpty;
              final bool isSelected =
                  selectedDate != null && DateUtils.isSameDay(selectedDate, date);
              final bool isToday = DateUtils.isSameDay(date, DateTime.now());
              final ColorScheme scheme = Theme.of(context).colorScheme;

              Color? background;
              Color borderColor = Colors.transparent;
              double borderWidth = 1;
              Color textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
              Set<ContestEventCategory> markers = <ContestEventCategory>{};

              if (hasEvents) {
                final ContestEventCategory dominantCategory = events.first.category;
                final Color baseColor = categoryColor(dominantCategory);
                markers = events.map((ContestEvent e) => e.category).toSet();
                background = isSelected
                    ? baseColor.withOpacity(0.28)
                    : baseColor.withOpacity(0.18);
                borderColor = baseColor;
                final Brightness brightness = ThemeData.estimateBrightnessForColor(baseColor);
                textColor = brightness == Brightness.dark ? Colors.white : Colors.black87;
              } else if (isSelected) {
                background = scheme.primary.withOpacity(0.12);
                borderColor = scheme.primary;
                textColor = scheme.onPrimaryContainer;
              }

              if (isToday && !hasEvents && !isSelected) {
                borderColor = scheme.primary;
                borderWidth = 1.5;
              }

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: hasEvents ? () => onDaySelected(date) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: borderColor,
                        width: borderColor == Colors.transparent ? 0 : borderWidth,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          dayNumber.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                        ),
                        if (hasEvents)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: markers
                                  .take(3)
                                  .map(
                                    (ContestEventCategory category) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 1),
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: categoryColor(category),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.color,
  });

  final ContestEvent event;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 8,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectedDayDetailsCard extends StatelessWidget {
  const _SelectedDayDetailsCard({
    super.key,
    required this.date,
    required this.events,
    required this.resolveColor,
  });

  final DateTime date;
  final List<ContestEvent> events;
  final Color Function(ContestEventCategory category) resolveColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localizations.formatFullDate(date),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Text('Aucun jalon officiel n’est prévu à cette date.')
            else
              for (int i = 0; i < events.length; i++) ...<Widget>[
                _EventTile(
                  event: events[i],
                  color: resolveColor(events[i].category),
                ),
                if (i != events.length - 1) const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class _YearTimelineCard extends StatelessWidget {
  const _YearTimelineCard({
    required this.year,
    required this.events,
    required this.resolveColor,
  });

  final int year;
  final List<ContestEvent> events;
  final Color Function(ContestEventCategory category) resolveColor;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Jalons $year',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < events.length; i++) ...<Widget>[
              _TimelineTile(
                event: events[i],
                color: resolveColor(events[i].category),
                localizations: localizations,
              ),
              if (i != events.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.event,
    required this.color,
    required this.localizations,
  });

  final ContestEvent event;
  final Color color;
  final MaterialLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                localizations.formatMediumDate(event.date),
                style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                event.title,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _categoryLabels[event.category]!,
                style: textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

