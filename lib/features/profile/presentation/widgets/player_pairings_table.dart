import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/profile_models.dart';

/// Riepilogo delle relazioni sulle partite con esito nel periodo.
class PlayerPairingsTable extends StatelessWidget {
  const PlayerPairingsTable({super.key, required this.stats});
  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    Widget person(PlayerHighlightPerson? value) => value == null
        ? const Text('—')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                '${value.matches} ${value.matches == 1 ? 'partita' : 'partite'} · ${value.wins} V / ${value.losses} S',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          );
    final rows = <(String, Widget)>[
      (
        'Compagni diversi',
        Text(
          '${stats.partnersCount}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      (
        'Avversari diversi',
        Text(
          '${stats.opponentsCount}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      (
        'Compagni più frequenti',
        stats.mostFrequentPartners.isEmpty
            ? const Text('—')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in stats.mostFrequentPartners)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: person(entry),
                    ),
                ],
              ),
      ),
      ('Miglior compagno per rendimento', person(stats.bestPartner)),
      ('Avversario più affrontato', person(stats.mostFacedOpponent)),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compagni e avversari',
            style: TextStyle(
              fontFamily: context.fonts.heading,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${stats.pairingsMatches} partite con esito nel periodo.',
            style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(.9),
              1: FlexColumnWidth(1.2),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            border: TableBorder(
              horizontalInside: BorderSide(color: context.colors.border),
            ),
            children: [
              TableRow(
                children: [
                  for (final title in ['Dato', 'Risultato'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              for (final row in rows)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                      child: Text(
                        row.$1,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: row.$2,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'V e S si riferiscono al giocatore. Miglior compagno per percentuale di vittorie, con almeno 2 partite quando disponibili.',
            style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
