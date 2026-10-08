import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bottom_bar.dart';

/// Contenitore delle 4 tab principali.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: AppBottomBar(
      currentIndex: navigationShell.currentIndex,
      onSelected: (index) => navigationShell.goBranch(
        index,
        // Un secondo tocco sulla tab attiva torna alla sua schermata iniziale.
        initialLocation: index == navigationShell.currentIndex,
      ),
    ),
  );
}
