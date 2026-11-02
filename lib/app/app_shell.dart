import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/app_menu/domain/app_menu_configuration.dart';
import '../features/app_menu/presentation/app_menu_provider.dart';
import 'bottom_bar.dart';

/// Contenitore delle tab principali abilitate per il circolo.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration =
        ref.watch(appMenuConfigurationProvider).value ??
        AppMenuConfiguration.allEnabled;
    final visibleTabs = appTabs
        .where((tab) => configuration.isEnabled(tab.feature))
        .toList(growable: false);
    final currentIndex = visibleTabs.indexWhere(
      (tab) => tab.branchIndex == navigationShell.currentIndex,
    );
    if (currentIndex < 0 && visibleTabs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationShell.goBranch(
          visibleTabs.first.branchIndex,
          initialLocation: true,
        );
      });
    }
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: visibleTabs.isEmpty
          ? null
          : AppBottomBar(
              tabs: visibleTabs,
              currentIndex: currentIndex < 0 ? 0 : currentIndex,
              onSelected: (index) {
                final branchIndex = visibleTabs[index].branchIndex;
                navigationShell.goBranch(
                  branchIndex,
                  // Prenota deve sempre riaprire la griglia normale: i parametri usati
                  // dai flussi «Crea partita» e «Lezione» non devono restare memorizzati
                  // nello stack della tab dopo che l'utente è tornato altrove.
                  // Per le altre tab, un secondo tocco torna alla schermata iniziale.
                  initialLocation:
                      branchIndex == 1 ||
                      branchIndex == navigationShell.currentIndex,
                );
              },
            ),
    );
  }
}
