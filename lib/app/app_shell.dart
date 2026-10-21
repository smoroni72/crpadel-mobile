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
        // Prenota deve sempre riaprire la griglia normale: i parametri usati
        // dai flussi «Crea partita» e «Lezione» non devono restare memorizzati
        // nello stack della tab dopo che l'utente è tornato altrove.
        // Per le altre tab, un secondo tocco torna alla schermata iniziale.
        initialLocation: index == 1 || index == navigationShell.currentIndex,
      ),
    ),
  );
}
