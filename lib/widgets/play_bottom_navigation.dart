import 'package:flutter/material.dart';

class PlayNavDestination {
  final IconData icon;
  final String label;

  const PlayNavDestination({
    required this.icon,
    required this.label,
  });
}

const List<PlayNavDestination> kPlayBottomNavDestinations = [
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

const int kPlayBottomNavQuizIndex = 2;

class PlayBottomNavigationBar extends StatelessWidget {
  const PlayBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.showFabNotch = true,
    this.backgroundColor = const Color(0xFF6C4DFF),
    this.highlightColor = const Color(0x29FFFFFF),
    this.selectedIconColor = Colors.white,
    this.unselectedIconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
    this.notchMargin = 8,
    this.fabGapWidth = 68,
  })  : assert(items.length > 1, 'items must contain at least two destinations.'),
        assert(selectedIndex >= 0 && selectedIndex < items.length,
            'selectedIndex must be within the bounds of items.');

  final List<PlayNavDestination> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final bool showFabNotch;
  final Color backgroundColor;
  final Color highlightColor;
  final Color selectedIconColor;
  final Color? unselectedIconColor;
  final EdgeInsetsGeometry padding;
  final double notchMargin;
  final double fabGapWidth;

  @override
  Widget build(BuildContext context) {
    final unselected = unselectedIconColor ?? selectedIconColor.withOpacity(0.72);
    final notchIndex = (items.length / 2).floor();
    final buttons = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      if (showFabNotch && i == notchIndex) {
        buttons.add(SizedBox(width: fabGapWidth));
      }
      buttons.add(
        Expanded(
          child: _NavButton(
            destination: items[i],
            isSelected: selectedIndex == i,
            highlightColor: highlightColor,
            selectedColor: selectedIconColor,
            unselectedColor: unselected,
            onTap: onItemSelected == null ? null : () => onItemSelected!(i),
          ),
        ),
      );
    }

    return BottomAppBar(
      shape: showFabNotch ? const CircularNotchedRectangle() : null,
      notchMargin: showFabNotch ? notchMargin : 0,
      color: backgroundColor,
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
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
    required this.isSelected,
    required this.highlightColor,
    required this.selectedColor,
    required this.unselectedColor,
    this.onTap,
  });

  final PlayNavDestination destination;
  final bool isSelected;
  final Color highlightColor;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? selectedColor : unselectedColor;
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
              onTap: onTap,
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
