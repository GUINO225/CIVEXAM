import 'package:flutter/material.dart';

class PlayNavDestination {
  final IconData icon;
  final String label;

  const PlayNavDestination({
    required this.icon,
    required this.label,
  });
}

const List<PlayNavDestination> playNavDestinations = [
  PlayNavDestination(
    icon: Icons.home_outlined,
    label: 'Accueil',
  ),
  PlayNavDestination(
    icon: Icons.dashboard_outlined,
    label: 'Dashboard',
  ),
  PlayNavDestination(
    icon: Icons.quiz_outlined,
    label: 'Quiz',
  ),
  PlayNavDestination(
    icon: Icons.history,
    label: 'Historique',
  ),
  PlayNavDestination(
    icon: Icons.person_outline,
    label: 'Profil',
  ),
  PlayNavDestination(
    icon: Icons.settings_outlined,
    label: 'Paramètres',
  ),
];

class PlayBottomNavBar extends StatelessWidget {
  const PlayBottomNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.notchShape = const CircularNotchedRectangle(),
    this.notchMargin = 8,
    this.addCenterFabSpacing = true,
    this.fabSpacingWidth = 68,
    this.backgroundColor = defaultBackgroundColor,
    this.highlightColor = defaultHighlightColor,
    this.foregroundColor,
  });

  static const Color defaultBackgroundColor = Color(0xFF6C4DFF);
  static const Color defaultHighlightColor = Color(0x29FFFFFF);

  final List<PlayNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final NotchedShape? notchShape;
  final double notchMargin;
  final bool addCenterFabSpacing;
  final double fabSpacingWidth;
  final Color backgroundColor;
  final Color highlightColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];
    final total = destinations.length;
    final centerIndex = addCenterFabSpacing ? (total / 2).floor() : null;

    for (var i = 0; i < total; i++) {
      if (addCenterFabSpacing && centerIndex != null && i == centerIndex) {
        buttons.add(SizedBox(width: fabSpacingWidth));
      }
      buttons.add(
        Expanded(
          child: _NavButton(
            destination: destinations[i],
            index: i,
            isSelected: i == selectedIndex,
            onSelected: onDestinationSelected,
            highlightColor: highlightColor,
            foregroundColor: foregroundColor,
          ),
        ),
      );
    }

    return BottomAppBar(
      shape: notchShape,
      notchMargin: notchMargin,
      color: backgroundColor,
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: buttons,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.destination,
    required this.index,
    required this.isSelected,
    required this.onSelected,
    required this.highlightColor,
    this.foregroundColor,
  });

  final PlayNavDestination destination;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onSelected;
  final Color highlightColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final Color baseForeground = foregroundColor ?? Colors.white;
    final Color iconColor =
        isSelected ? baseForeground : baseForeground.withOpacity(0.72);

    return Center(
      child: Semantics(
        label: destination.label,
        selected: isSelected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: Tooltip(
            message: destination.label,
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? highlightColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(destination.icon, color: iconColor, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
