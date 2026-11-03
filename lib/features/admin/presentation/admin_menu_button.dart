import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';

class AdminMenuButton extends ConsumerWidget {
  const AdminMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    if (user?.isAdmin != true) return const SizedBox.shrink();
    final items = <_AdminMenuItem>[
      const _AdminMenuItem(
        'dashboard',
        'Dashboard',
        Icons.dashboard_outlined,
        AppRoutes.admin,
      ),
      if (user!.canAccessAdminMenu('matches')) ...[
        const _AdminMenuItem(
          'matches',
          'Partite',
          Icons.sports_tennis,
          AppRoutes.adminMatches,
        ),
        const _AdminMenuItem(
          'history',
          'Storico partite',
          Icons.history,
          AppRoutes.adminMatchHistory,
        ),
      ],
      if (user.canAccessAdminMenu('bookings'))
        const _AdminMenuItem(
          'bookings',
          'Prenotazioni campi',
          Icons.calendar_month_outlined,
          AppRoutes.adminBookings,
        ),
      if (user.canAccessAdminMenu('players'))
        const _AdminMenuItem(
          'players',
          'Giocatori',
          Icons.groups_outlined,
          AppRoutes.adminPlayers,
        ),
      if (user.canAccessAdminMenu('users'))
        const _AdminMenuItem(
          'users',
          'Utenti',
          Icons.manage_accounts_outlined,
          AppRoutes.adminUsers,
        ),
      if (user.canAccessAdminMenu('statistics'))
        const _AdminMenuItem(
          'statistics',
          'Statistiche',
          Icons.query_stats,
          AppRoutes.adminStatistics,
        ),
      if (user.canAccessAdminMenu('rankings'))
        const _AdminMenuItem(
          'rankings',
          'Classifiche',
          Icons.leaderboard_outlined,
          AppRoutes.rankings,
        ),
      if (user.canAccessAdminMenu('push_notifications'))
        const _AdminMenuItem(
          'push',
          'Notifiche push',
          Icons.campaign_outlined,
          AppRoutes.adminCommunications,
        ),
    ];
    return PopupMenuButton<String>(
      tooltip: 'Menu amministratore',
      icon: const Icon(Icons.admin_panel_settings_outlined),
      position: PopupMenuPosition.under,
      onSelected: (route) => context.pushNamed(route),
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'CRPADEL ADMIN',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        for (final item in items)
          PopupMenuItem<String>(
            value: item.route,
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: context.colors.primary),
                const SizedBox(width: 12),
                Text(item.label),
              ],
            ),
          ),
      ],
    );
  }
}

class _AdminMenuItem {
  const _AdminMenuItem(this.key, this.label, this.icon, this.route);
  final String key;
  final String label;
  final IconData icon;
  final String route;
}
