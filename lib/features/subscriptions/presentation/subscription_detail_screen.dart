import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../profile/domain/profile_models.dart';
import '../../profile/presentation/profile_labels.dart';
import '../../profile/presentation/profile_providers.dart';
import '../domain/player_subscription.dart';

/// Dettaglio di un pacchetto o abbonamento (mockup 06). Fasce, tipi ammessi
/// e movimenti compaiono solo quando il backend li fornisce (lacuna n. 2).
class SubscriptionDetailScreen extends ConsumerWidget {
  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  final String subscriptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(allSubscriptionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Abbonamento')),
      body: AsyncValueView(
        value: all,
        errorText: 'Non riesco a caricare il pacchetto',
        onRetry: () => ref.invalidate(allSubscriptionsProvider),
        data: (list) {
          final s = list.where((x) => x.id == subscriptionId).firstOrNull;
          if (s == null) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Pacchetto non trovato'),
            );
          }
          return _Body(subscription: s);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.subscription});

  final PlayerSubscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = subscription;
    final colors = context.colors;
    final theme = Theme.of(context);
    final details = ref.watch(subscriptionDetailsProvider(s.id)).value;
    Widget number(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: context.fonts.monoStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: colors.textSecondary)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(s.planName, style: theme.textTheme.headlineSmall),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: s.isUsable ? colors.primaryTint : colors.divider,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                subscriptionStatusLabel(s.status),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: s.isUsable ? colors.primaryText : colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (s.isPackage) ...[
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  number('${s.matchesAvailable ?? 0}', 'disponibili'),
                  number('${s.matchesReserved}', 'riservate'),
                  number('${s.matchesUsed}', 'giocate'),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                row(
                  'Attivato',
                  s.activatedAt == null
                      ? 'Alla prima partita'
                      : Dates.numeric(s.activatedAt!.toLocal()),
                ),
                row(
                  'Scadenza',
                  s.expiresAt == null
                      ? '—'
                      : Dates.numeric(s.expiresAt!.toLocal()),
                ),
                if (s.soldByClubName != null)
                  row('Acquistato presso', s.soldByClubName!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Valido in tutti i circoli del gruppo.',
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
        if (details != null) ..._details(context, details),
      ],
    );
  }

  List<Widget> _details(BuildContext context, SubscriptionDetails d) {
    final colors = context.colors;
    final title = Theme.of(context).textTheme.titleMedium;
    final mono = context.fonts.monoStyle(fontSize: 14);
    return [
      if (d.windows.isNotEmpty || d.allowedMatchTypes.isNotEmpty) ...[
        const SizedBox(height: 22),
        Text('Quando puoi usarlo', style: title),
        Text(
          'Orari di inizio partita consentiti',
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final w in d.windows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 96,
                          child: Text(weekdayName(w.weekday)),
                        ),
                        // Con caratteri grandi va a capo invece di uscire.
                        Expanded(
                          child: Text(
                            '${w.startTime}–${w.latestStartTime}',
                            textAlign: TextAlign.right,
                            style: mono,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (d.allowedMatchTypes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tipi di partita: '
              '${d.allowedMatchTypes.map(matchTypeCodeLabel).join(', ')}',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ),
      ],
      if (d.movements.isNotEmpty) ...[
        const SizedBox(height: 22),
        Text('Movimenti', style: title),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (final m in d.movements)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movementLabel(m.type)),
                              Text(
                                [Dates.numeric(m.date), ?m.note].join(' · '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          m.delta > 0 ? '+${m.delta}' : '${m.delta}',
                          style: mono.copyWith(
                            fontWeight: FontWeight.w600,
                            color: m.delta > 0
                                ? colors.text
                                : colors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ];
  }
}
