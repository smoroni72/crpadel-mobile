import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../core/network/api_client.dart';

const legacyStatisticKeys = {'general', 'monthly', 'decades', 'attendance'};
final statisticPublicationProvider =
    FutureProvider.autoDispose<Map<String, bool>>((ref) async {
      try {
        final response = await ref
            .read(apiClientProvider)
            .get('/statistics/configuration');
        final data = Map<String, dynamic>.from(response.data['data'] as Map);
        return data.map(
          (key, value) => MapEntry(key, value is Map && value['app'] == true),
        );
      } on ApiException catch (error) {
        if (error.statusCode == 404) {
          return {for (final key in legacyStatisticKeys) key: true};
        }
        rethrow;
      }
    });
final publishedStatisticProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, key) async {
      final response = await ref
          .read(apiClientProvider)
          .get('/statistics/reports/$key', query: {'channel': 'app'});
      return Map<String, dynamic>.from(response.data as Map);
    });

class StatisticVisibility extends ConsumerWidget {
  const StatisticVisibility({
    super.key,
    required this.reportKey,
    required this.child,
  });
  final String reportKey;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(statisticPublicationProvider)
      .when(
        data: (data) =>
            data[reportKey] == true ? child : const SizedBox.shrink(),
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const SizedBox.shrink(),
      );
}

List<Map<String, dynamic>> statisticPodium(
  List<Map<String, dynamic>> rows,
  String key,
) {
  num number(dynamic value) => value is num ? value : 0;
  final list = rows
      .where(
        (p) => key == 'challenge' ? p['index'] is num : number(p['played']) > 0,
      )
      .toList();
  int byRate(Map<String, dynamic> a, Map<String, dynamic> b) =>
      number(b['percentage']).compareTo(number(a['percentage']));
  if (key == 'challenge') {
    list.sort((a, b) => number(b['index']).compareTo(number(a['index'])));
  } else if (key == 'final_tiebreaks') {
    list.removeWhere((p) => number(p['played']) < 5);
    list.sort((a, b) {
      final rate = byRate(a, b);
      return rate != 0 ? rate : number(b['won']).compareTo(number(a['won']));
    });
  } else {
    list.sort((a, b) {
      final played = number(b['played']).compareTo(number(a['played']));
      return played != 0
          ? played
          : number(b['won']).compareTo(number(a['won']));
    });
    final chosen = list.take(3).toList()..sort(byRate);
    return chosen;
  }
  return list.take(3).toList();
}

class PublishedStatistics extends ConsumerWidget {
  const PublishedStatistics({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(statisticPublicationProvider).asData?.value ?? {};
    return Column(
      children: [
        for (final key in ['tiebreaks', 'final_tiebreaks', 'challenge'])
          if (visible[key] == true) _StatisticReport(reportKey: key),
      ],
    );
  }
}

class _StatisticReport extends ConsumerStatefulWidget {
  const _StatisticReport({required this.reportKey});
  final String reportKey;
  @override
  ConsumerState<_StatisticReport> createState() => _StatisticReportState();
}

class _StatisticReportState extends ConsumerState<_StatisticReport> {
  bool expanded = false;
  String format(dynamic n) =>
      n is num ? NumberFormat('0.#', 'it_IT').format(n) : '—';
  @override
  Widget build(BuildContext context) {
    final result = ref.watch(publishedStatisticProvider(widget.reportKey));
    return result.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: LinearProgressIndicator(),
      ),
      error: (error, stack) => error is ApiException && error.statusCode == 404
          ? const SizedBox.shrink()
          : TextButton(
              onPressed: () =>
                  ref.invalidate(publishedStatisticProvider(widget.reportKey)),
              child: const Text('Riprova statistiche'),
            ),
      data: (value) {
        final rows = (value['data'] as List)
            .map((p) => Map<String, dynamic>.from(p as Map))
            .where(
              (p) => widget.reportKey == 'challenge'
                  ? p['index'] is num
                  : (p['played'] as num) > 0,
            )
            .toList();
        final podium = statisticPodium(rows, widget.reportKey);
        final challenge = widget.reportKey == 'challenge';
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value['report']['title'] as String,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(value['report']['description'] as String),
                if (widget.reportKey == 'final_tiebreaks')
                  const Text(
                    'Podio con almeno 5 finali conclusi, ordinato per percentuale di vittorie.',
                  ),
                for (var i = 0; i < podium.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      '${i + 1}°',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    title: Text(podium[i]['name'] as String),
                    subtitle: Text(
                      challenge
                          ? '${podium[i]['animal']} · ${podium[i]['matches']} partite valutate'
                          : '${podium[i]['played']} giocati · ${podium[i]['won']} vinti · ${podium[i]['lost']} persi',
                    ),
                    trailing: Text(
                      challenge
                          ? '${format(podium[i]['index'])}/100'
                          : podium[i]['percentage'] == null
                          ? '—'
                          : '${format(podium[i]['percentage'])}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Giocatore')),
                      if (challenge) ...[
                        const DataColumn(label: Text('Indice')),
                        const DataColumn(label: Text('Animaletto')),
                        const DataColumn(label: Text('Partite')),
                      ] else ...[
                        const DataColumn(label: Text('Giocati')),
                        const DataColumn(label: Text('Vinti')),
                        const DataColumn(label: Text('Persi')),
                        const DataColumn(label: Text('% vittorie')),
                      ],
                    ],
                    rows: [
                      for (final p in expanded ? rows : rows.take(10))
                        DataRow(
                          cells: [
                            DataCell(Text(p['name'] as String)),
                            if (challenge) ...[
                              DataCell(Text(format(p['index']))),
                              DataCell(Text(p['animal'] as String)),
                              DataCell(Text(format(p['matches']))),
                            ] else ...[
                              DataCell(Text(format(p['played']))),
                              DataCell(Text(format(p['won']))),
                              DataCell(Text(format(p['lost']))),
                              DataCell(
                                Text(
                                  p['percentage'] == null
                                      ? '—'
                                      : '${format(p['percentage'])}%',
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
                if (rows.length > 10)
                  TextButton(
                    onPressed: () => setState(() => expanded = !expanded),
                    child: Text(
                      expanded
                          ? 'Mostra i primi 10'
                          : 'Mostra tutti (${rows.length})',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
