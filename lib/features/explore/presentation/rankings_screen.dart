import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../profile/domain/profile_models.dart';
import 'explore_providers.dart';

class RankingsScreen extends ConsumerStatefulWidget {
  const RankingsScreen({super.key});

  @override
  ConsumerState<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends ConsumerState<RankingsScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  String get _monthKey => DateFormat('yyyy-MM').format(_month);

  Future<void> _refresh() async {
    await Future.wait([
      ref.refresh(fullRankingsProvider.future),
      ref.refresh(monthlyRankingsProvider(_monthKey).future),
    ]);
  }

  Future<void> _selectMonth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      helpText: 'Seleziona un giorno del mese',
      cancelText: 'Annulla',
      confirmText: 'Scegli mese',
    );
    if (selected != null) {
      setState(() => _month = DateTime(selected.year, selected.month));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Classifiche')),
    body: RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _MonthlyHeader(month: _month, onSelectMonth: _selectMonth),
          const SizedBox(height: 12),
          AsyncValueView(
            value: ref.watch(monthlyRankingsProvider(_monthKey)),
            errorText: 'Non riesco a caricare la classifica mensile',
            onRetry: () => ref.invalidate(monthlyRankingsProvider(_monthKey)),
            data: (result) => _MonthlyRankingSection(result: result),
          ),
          const SizedBox(height: 28),
          Text(
            'Classifica generale',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Graduatoria ufficiale aggiornata',
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 12),
          AsyncValueView(
            value: ref.watch(fullRankingsProvider),
            errorText: 'Non riesco a caricare la classifica',
            onRetry: () => ref.invalidate(fullRankingsProvider),
            data: (players) => players.isEmpty
                ? const Center(child: Text('Nessun giocatore in classifica'))
                : Column(
                    children: [
                      for (var index = 0; index < players.length; index++) ...[
                        _RankingRow(
                          player: players[index],
                          position: players[index].position > 0
                              ? players[index].position
                              : index + 1,
                        ),
                        if (index < players.length - 1)
                          const SizedBox(height: 8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

class _MonthlyHeader extends StatelessWidget {
  const _MonthlyHeader({required this.month, required this.onSelectMonth});

  final DateTime month;
  final VoidCallback onSelectMonth;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Classifica mensile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Media dei PR conquistati per partita × 10',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
      OutlinedButton.icon(
        onPressed: onSelectMonth,
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
        icon: const Icon(Icons.calendar_month_outlined, size: 18),
        label: Text(_monthLabel(month)),
      ),
    ],
  );
}

class _MonthlyRankingSection extends StatelessWidget {
  const _MonthlyRankingSection({required this.result});

  final MonthlyRankingResult result;

  @override
  Widget build(BuildContext context) {
    final winner = result.playerOfTheMonth;
    if (winner == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: context.colors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'Nessun punto ranking assegnato nel mese',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Servono almeno ${result.minimumMatches} partite nel mese per comparire',
          style: TextStyle(fontSize: 12, color: context.colors.primaryText),
        ),
        const SizedBox(height: 10),
        Card(
          color: const Color(0xFFFFC107).withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0x33FFC107),
                  child: Icon(Icons.emoji_events, color: Color(0xFFFFB300)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GIOCATORE DEL MESE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: context.colors.primaryText,
                        ),
                      ),
                      Text(
                        winner.playerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${winner.matchesPlayed} partite · ${winner.matchesWon} vinte',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  _points(winner.monthlyScore),
                  style: context.fonts
                      .monoStyle(fontSize: 18, fontWeight: FontWeight.w700)
                      .copyWith(color: const Color(0xFFFFB300)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final player in result.players) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      '#${player.position}',
                      style: context.fonts.monoStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.playerName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${player.matchesPlayed} PG · ${player.matchesWon} V · ${_points(player.pointsEarned)} PR',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _points(player.monthlyScore),
                    style: context.fonts
                        .monoStyle(fontWeight: FontWeight.w700)
                        .copyWith(color: context.colors.primaryText),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.player, required this.position});
  final PlayerRanking player;
  final int position;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              '#$position',
              style: context.fonts.monoStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: _color(player.rankingBandColor),
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.border),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.playerName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${player.matchesPlayed} PG · ${player.matchesWon} V',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            player.eloScore.toStringAsFixed(
              player.eloScore == player.eloScore.roundToDouble() ? 0 : 1,
            ),
            style: context.fonts
                .monoStyle(fontWeight: FontWeight.w700)
                .copyWith(color: context.colors.primaryText),
          ),
        ],
      ),
    ),
  );
}

String _monthLabel(DateTime value) {
  final label = DateFormat('MMMM yyyy', 'it_IT').format(value);
  return '${label[0].toUpperCase()}${label.substring(1)}';
}

String _points(double value) => NumberFormat('0.0', 'it_IT').format(value);

Color _color(String? value) {
  final hex = value?.replaceFirst('#', '');
  if (hex == null || hex.length != 6) return Colors.white;
  final parsed = int.tryParse('FF$hex', radix: 16);
  return parsed == null ? Colors.white : Color(parsed);
}
