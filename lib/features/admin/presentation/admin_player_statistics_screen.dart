import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_value_view.dart';
import '../data/admin_repository.dart';
import 'admin_menu_button.dart';
import 'admin_providers.dart';

class AdminPlayerStatisticsScreen extends ConsumerWidget {
  const AdminPlayerStatisticsScreen({super.key, required this.player});

  final AdminPlayer player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(adminPlayerStatisticsProvider(player.id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche giocatore'),
        actions: const [AdminMenuButton()],
      ),
      body: AsyncValueView(
        value: statistics,
        errorText: 'Non riesco a caricare le statistiche del giocatore',
        onRetry: () => ref.invalidate(adminPlayerStatisticsProvider(player.id)),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(adminPlayerStatisticsProvider(player.id).future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(
                          player.name.isEmpty ? '?' : player.name[0],
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (player.email.isNotEmpty) Text(player.email),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Rendimento', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.55,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _Metric(
                    'Partite',
                    '${data.matchesPlayed}',
                    Icons.sports_tennis,
                  ),
                  _Metric(
                    'Vittorie / sconfitte',
                    '${data.wins} / ${data.losses}',
                    Icons.emoji_events_outlined,
                  ),
                  _Metric(
                    'Percentuale vittorie',
                    '${data.winRate}%',
                    Icons.trending_up,
                  ),
                  _Metric(
                    'Ranking',
                    '${data.rankingMatches}',
                    Icons.leaderboard_outlined,
                  ),
                  _Metric(
                    'Amichevoli',
                    '${data.friendlyMatches}',
                    Icons.groups_outlined,
                  ),
                  _Metric(
                    'Tornei',
                    '${data.tournamentMatches}',
                    Icons.workspace_premium_outlined,
                  ),
                  _Metric(
                    'Set vinti / persi',
                    '${data.setsWon} / ${data.setsLost}',
                    Icons.scoreboard_outlined,
                  ),
                  _Metric(
                    'Game vinti / persi',
                    '${data.gamesWon} / ${data.gamesLost}',
                    Icons.bar_chart,
                  ),
                  _Metric(
                    'Da sfavorito',
                    '${data.underdogMatches} · ${data.underdogWins} V',
                    Icons.south_east,
                  ),
                  _Metric(
                    'Da favorito',
                    '${data.favoriteMatches} · ${data.favoriteWins} V',
                    Icons.north_east,
                  ),
                  _Metric(
                    'Punti reali',
                    data.rankingPoints.toStringAsFixed(2),
                    Icons.add_chart,
                  ),
                  _Metric(
                    'Media punti reali',
                    data.averageRankingPoints.toStringAsFixed(2),
                    Icons.analytics_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _Warnings(data: data),
              const SizedBox(height: 18),
              Text(
                'Storico partite',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (data.matches.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Nessuna partita nel periodo disponibile.'),
                  ),
                )
              else
                for (final match in data.matches) ...[
                  _MatchCard(match: match),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.colors.primary),
          const SizedBox(height: 5),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _Warnings extends StatelessWidget {
  const _Warnings({required this.data});
  final AdminPlayerStatistics data;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Situazione ranking',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _line(
            context,
            'Partite consecutive da favorito',
            '${data.favoriteStreak}',
            data.favoriteStreak >= 3,
          ),
          const Divider(height: 22),
          _line(
            context,
            'Correzioni per decadi senza partite',
            data.decadeAdjustmentPoints.toStringAsFixed(2),
            data.decadeAdjustmentPoints < 0,
          ),
        ],
      ),
    ),
  );

  Widget _line(
    BuildContext context,
    String label,
    String value,
    bool warning,
  ) => Row(
    children: [
      Icon(
        warning ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: warning ? Colors.orange : Colors.green,
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(label)),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final AdminPlayerMatchStatistic match;

  String get formattedDate {
    final parsed = DateTime.tryParse(match.date);
    return parsed == null
        ? match.date
        : DateFormat('dd/MM/yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$formattedDate · ${match.time}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (match.score.isNotEmpty)
                Text(
                  match.score,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            match.court,
            style: TextStyle(color: context.colors.textSecondary),
          ),
          if (match.rankingPoints != null ||
              match.rankingScoreDelta != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (match.rankingPoints != null)
                  Chip(
                    label: Text('Punti reali ${_signed(match.rankingPoints!)}'),
                  ),
                if (match.rankingScoreDelta != null)
                  Chip(
                    label: Text(
                      'Punti classifica ${_signed(match.rankingScoreDelta!)}',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
  );

  String _signed(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}';
}
