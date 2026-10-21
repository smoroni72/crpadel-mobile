import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../notifications/presentation/notifications_provider.dart';

class ExploreMenuScreen extends ConsumerWidget {
  const ExploreMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;
    final items = <_MenuItem>[
      const _MenuItem(
        'Tornei',
        Icons.emoji_events_outlined,
        AppRoutes.tournaments,
      ),
      const _MenuItem(
        'Classifiche',
        Icons.leaderboard_outlined,
        AppRoutes.rankings,
      ),
      const _MenuItem('Lezioni', Icons.school_outlined, AppRoutes.lessons),
      const _MenuItem(
        'Gallery',
        Icons.photo_library_outlined,
        AppRoutes.gallery,
      ),
      _MenuItem(
        'Centro notifiche',
        Icons.notifications_none,
        AppRoutes.notifications,
        badge: unread,
      ),
      const _MenuItem(
        'Informazioni sul circolo',
        Icons.location_on_outlined,
        AppRoutes.clubInfo,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => Divider(color: context.colors.divider),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            minTileHeight: 66,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Icon(item.icon, color: context.colors.primaryText),
            title: Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.badge > 0)
                  Badge(label: Text(item.badge > 99 ? '99+' : '${item.badge}')),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => context.pushNamed(item.route),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.label, this.icon, this.route, {this.badge = 0});
  final String label;
  final IconData icon;
  final String route;
  final int badge;
}
