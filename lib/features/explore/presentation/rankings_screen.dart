import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../profile/domain/profile_models.dart';
import 'explore_providers.dart';

class RankingsScreen extends ConsumerWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Classifiche')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(fullRankingsProvider.future),
      child: AsyncValueView(
        value: ref.watch(fullRankingsProvider),
        errorText: 'Non riesco a caricare la classifica',
        onRetry: () => ref.invalidate(fullRankingsProvider),
        data: (players) => players.isEmpty
            ? const Center(child: Text('Nessun giocatore in classifica'))
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                itemCount: players.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) => _RankingRow(
                  player: players[index],
                  position: players[index].position > 0
                      ? players[index].position
                      : index + 1,
                ),
              ),
      ),
    ),
  );
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
                  '${player.matchesWon} vittorie su ${player.matchesPlayed}',
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

Color _color(String? value) {
  final hex = value?.replaceFirst('#', '');
  if (hex == null || hex.length != 6) return Colors.white;
  final parsed = int.tryParse('FF$hex', radix: 16);
  return parsed == null ? Colors.white : Color(parsed);
}
