import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/padel_match.dart';
import '../match_labels.dart';
import 'player_ranking_marker.dart';

/// Riepilogo mobile della partita, con le due squadre disposte in verticale.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.myUserId,
    this.onJoin,
    this.onTap,
    this.onCancel,
  });

  final PadelMatch match;
  final String myUserId;
  final VoidCallback? onJoin;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mine = match.involves(myUserId);
    final open = match.hasFreeSpots;
    final completed = match.status == MatchStatus.completed;

    return Card(
      key: ValueKey('match-card-${match.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: colors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      match.courtName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusBadge(match: match),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _TypeBadge(match.matchType.label),
                      const Spacer(),
                      Text(
                        match.slot?.label ?? match.timeSlot,
                        style: context.fonts.monoStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TeamSummary(
                    label: 'SQUADRA A',
                    players: match.teamA,
                    coefficient: match.teamCoefficient('A'),
                    myUserId: myUserId,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  _TeamSummary(
                    label: 'SQUADRA B',
                    players: match.teamB,
                    coefficient: match.teamCoefficient('B'),
                    myUserId: myUserId,
                  ),
                  if (completed && (match.scoreTeam1?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: colors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        match.scoreTeam1!,
                        style: context.fonts
                            .monoStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            )
                            .copyWith(color: colors.primaryText),
                      ),
                    ),
                  ],
                  if (open && !mine && onJoin != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      key: ValueKey('join-match-${match.id}'),
                      onPressed: onJoin,
                      icon: const Icon(Icons.person_add_alt, size: 18),
                      label: const Text('Partecipa'),
                    ),
                  ],
                  if (onCancel != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: ValueKey('cancel-match-${match.id}'),
                      onPressed: onCancel,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Annulla partita'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.match});

  final PadelMatch match;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        match.statusLabel.split(' · ').first,
        style: TextStyle(
          color: match.status == MatchStatus.open
              ? colors.matchOpen
              : colors.text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: context.colors.divider,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: context.colors.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _TeamSummary extends StatelessWidget {
  const _TeamSummary({
    required this.label,
    required this.players,
    required this.coefficient,
    required this.myUserId,
  });

  final String label;
  final List<MatchPlayer> players;
  final double? coefficient;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            if (coefficient != null)
              Text(
                'Coeff. coppia ${coefficientLabel(coefficient)}',
                style: context.fonts.monoStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        if (players.isEmpty)
          Text(
            'Nessun giocatore',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          )
        else
          for (final player in players)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  PlayerRankingMarker(colorHex: player.rankingBandColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: player.userId == myUserId
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (player.userId == myUserId)
                    Text(
                      'TU',
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
        for (var i = players.length; i < 2; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '○ Posto disponibile',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ),
      ],
    );
  }
}
