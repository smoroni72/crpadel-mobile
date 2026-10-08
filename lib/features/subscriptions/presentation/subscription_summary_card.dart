import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Riferimento a pacchetti e abbonamenti in Home. Segnaposto fino alla
/// Fase 1, quando mostrerà i dati di `/subscriptions/mine`.
class SubscriptionSummaryCard extends StatelessWidget {
  const SubscriptionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) => const Card(
    color: AppTheme.navy,
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Abbonamento e pacchetti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'La situazione aggiornata sarà mostrata qui.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    ),
  );
}
