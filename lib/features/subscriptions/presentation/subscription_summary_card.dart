import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../domain/player_subscription.dart';

/// Riferimento piccolo al pacchetto in Home: anello, partite disponibili e
/// scadenza. Il dettaglio arriva nella Fase 4.
class SubscriptionSummaryCard extends StatelessWidget {
  const SubscriptionSummaryCard({
    super.key,
    required this.subscription,
    this.otherCount = 0,
  });

  final PlayerSubscription subscription;

  /// Altri pacchetti utilizzabili oltre a questo.
  final int otherCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = subscription;
    final total = s.matchesTotal ?? 0;
    final available = s.matchesAvailable ?? 0;
    final progress = s.isPackage && total > 0 ? available / total : 1.0;

    final title = s.isPackage
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$available/$total',
                  style: context.fonts.monoStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' partite nel pacchetto'),
              ],
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          )
        : Text(
            s.planName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          );

    final details = [
      if (s.isPackage) s.planName else 'Abbonamento',
      switch (s.expiresAt) {
        final expiry? => 'scade ${Dates.dayMonth(expiry.toLocal())}',
        null => 'si attiva alla prima partita',
      },
      if (otherCount > 0) '+$otherCount',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 40,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              color: colors.primary,
              backgroundColor: colors.divider,
              semanticsLabel: 'Partite disponibili',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                Text(
                  details,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
