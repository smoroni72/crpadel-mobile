import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlayerExpectedPerformance extends StatelessWidget {
  const PlayerExpectedPerformance({super.key, required this.value});
  final Map<String, dynamic>? value;

  @override
  Widget build(BuildContext context) {
    final e = value;
    if (e == null) return const SizedBox.shrink();
    final ready = e['status'] == 'ready';
    final raw = (e['extra_wins_per_10'] as num?)?.toDouble();
    final delta = raw != null && raw.abs() < .005 ? 0.0 : raw;
    final format = NumberFormat('0.00', 'it_IT');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rendimento rispetto alle attese',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (ready && delta != null) ...[
              Text(
                '${delta >= 0 ? '+' : '−'}${format.format(delta.abs())}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: delta >= 0 ? Colors.green : Colors.orange,
                ),
              ),
              const Text('vittorie ogni 10 partite rispetto alle attese'),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in [
                    ('${e['matches_played'] ?? 0}', 'Partite valutate'),
                    ('${e['wins'] ?? 0}', 'Vittorie ottenute'),
                    (
                      NumberFormat(
                        '0.0',
                        'it_IT',
                      ).format(e['expected_wins'] ?? 0),
                      'Vittorie attese',
                    ),
                  ])
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            item.$1,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Un valore positivo indica più vittorie del previsto; un valore negativo, meno vittorie del previsto.',
              ),
              if ((e['excluded_matches'] as num? ?? 0) > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '${(e['matches_played'] as num? ?? 0) + (e['excluded_matches'] as num? ?? 0)} partite Ranking registrate · ${e['matches_played']} valutate',
                ),
                Text(
                  '${e['excluded_matches']} ${(e['excluded_matches'] as num) == 1 ? 'partita esclusa' : 'partite escluse'}: il rendimento considera solo incontri con vincitore e coefficienti completi.',
                ),
                if ((e['excluded_details'] as List? ?? []).isNotEmpty)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Vedi le partite escluse'),
                    children: [
                      for (final m in e['excluded_details'] as List)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${m['date']?.split('-').reversed.join('/')} · ${m['time'] ?? 'Orario non indicato'}',
                          ),
                          subtitle: Text('${m['reason']}'),
                        ),
                    ],
                  ),
              ],
            ] else
              Text(
                e['status'] == 'no_matches'
                    ? 'Nessuna partita Ranking con vincitore e coefficienti completi.'
                    : 'Dati insufficienti per una stima.',
              ),
          ],
        ),
      ),
    );
  }
}
