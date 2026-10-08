import 'package:flutter/material.dart';

class AppTab {
  const AppTab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const appTabs = [
  AppTab('Home', Icons.home_outlined, Icons.home),
  AppTab('Prenota', Icons.calendar_month_outlined, Icons.calendar_month),
  AppTab('Partite', Icons.sports_tennis_outlined, Icons.sports_tennis),
  AppTab('Profilo', Icons.person_outline, Icons.person),
];

/// Barra in basso dell'app. Provvisoria: verrà sostituita dal template
/// scelto, mantenendo la stessa interfaccia.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onSelected,
    destinations: [
      for (final tab in appTabs)
        NavigationDestination(
          icon: Icon(tab.icon),
          selectedIcon: Icon(tab.selectedIcon),
          label: tab.label,
        ),
    ],
  );
}
