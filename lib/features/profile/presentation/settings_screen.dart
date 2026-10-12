import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/config/current_club.dart';
import '../../../core/push/push_controller.dart';
import '../../../core/push/push_messaging.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/brand_config.dart';
import '../../bookings/presentation/book_providers.dart';
import '../../bookings/presentation/widgets/preferred_time_sheet.dart';

/// Voci presenti solo nell'app, fuori dal Profilo che resta uguale al sito.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferred = ref.watch(preferredTimeProvider).value;
    final club = ref.watch(currentClubProvider);
    final push = ref.watch(pushPermissionProvider);
    final colors = context.colors;
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
                  title: 'Notifiche',
                  value: switch (push) {
                    PushPermission.granted => 'Attive',
                    PushPermission.denied => 'Disattivate',
                    PushPermission.notDetermined => 'Attiva',
                    PushPermission.unavailable => 'Non disponibili',
                  },
                  onTap: switch (push) {
                    PushPermission.notDetermined =>
                      () => ref
                          .read(pushPermissionProvider.notifier)
                          .requestPermission(),
                    PushPermission.denied =>
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Le notifiche sono disattivate: puoi attivarle '
                            "nelle impostazioni del telefono, alla voce dell'app.",
                          ),
                        ),
                      ),
                    _ => null,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
            child: Text(
              "Voci presenti solo nell'app: il resto del Profilo è uguale "
              'al sito.',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
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
