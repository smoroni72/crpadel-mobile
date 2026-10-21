import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/config/current_club.dart';
import '../../../core/push/push_controller.dart';
import '../../../core/push/push_messaging.dart';
import '../../../core/push/push_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/brand_config.dart';
import '../../bookings/presentation/book_providers.dart';
import '../../bookings/presentation/widgets/preferred_time_sheet.dart';
import '../../notifications/presentation/notifications_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferred = ref.watch(preferredTimeProvider).value;
    final club = ref.watch(currentClubProvider);
    final push = ref.watch(pushPermissionProvider);
    final pushEnabled = ref.watch(pushNotificationsEnabledProvider);
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _Item(
                  title: 'Circolo',
                  // Il nome arriverà dalla configurazione del circolo (Fase 0b).
                  value: club == null ? '—' : BrandConfig.crpadel.displayName,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Potrai cambiare circolo quando ce ne saranno altri '
                        "nell'app.",
                      ),
                    ),
                  ),
                ),
                _Item(
                  title: 'Orario preferito',
                  value: preferred?.label ?? 'Non impostato',
                  onTap: () => showPreferredTimeSheet(context),
                ),
                _Item(
                  title: 'Centro notifiche',
                  value: unread == 0
                      ? 'Nessuna da leggere'
                      : '$unread da leggere',
                  onTap: () => context.pushNamed(AppRoutes.notifications),
                ),
                _SwitchItem(
                  title: 'Avvisi sul dispositivo',
                  subtitle: push == PushPermission.unavailable
                      ? 'Non disponibili su questo dispositivo'
                      : 'Ricevi le comunicazioni anche quando l’app è chiusa',
                  value:
                      (pushEnabled.value ?? true) &&
                      push == PushPermission.granted,
                  enabled:
                      push != PushPermission.unavailable &&
                      !pushEnabled.isLoading,
                  onChanged: (enabled) async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (!enabled) {
                      await ref
                          .read(pushPermissionProvider.notifier)
                          .disableNotifications();
                      if (context.mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Avvisi disattivati. Il Centro notifiche resta disponibile.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    final result = await ref
                        .read(pushPermissionProvider.notifier)
                        .enableNotifications();
                    if (!context.mounted) return;
                    if (result == PushPermission.granted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Avvisi attivati')),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Per attivare gli avvisi, abilita le notifiche nelle impostazioni del telefono.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                _Item(
                  title: 'Cambia password',
                  onTap: () => context.goNamed(AppRoutes.changePassword),
                  last: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  const _SwitchItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.fromLTRB(16, 7, 8, 7),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15)),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.title,
    this.value,
    required this.onTap,
    this.last = false,
  });

  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: colors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: onTap == null ? colors.textSecondary : colors.text,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: colors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}
