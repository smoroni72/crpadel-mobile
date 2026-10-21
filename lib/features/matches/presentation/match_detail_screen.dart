import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bookings/presentation/cancel_booking.dart';
import '../../bookings/presentation/widgets/player_picker_sheet.dart';
import '../domain/padel_match.dart';
import 'match_labels.dart';
import 'match_providers.dart';
import 'widgets/result_sheet.dart';
import 'widgets/player_ranking_marker.dart';

/// Dettaglio partita: squadre, richieste (per l'organizzatore) e azioni.
class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchDetailProvider(matchId));
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: match.value == null
            ? const Text('Partita')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.value!.courtName} · ${match.value!.matchType.label}',
                  ),
                  Text(
                    [
                      Dates.longDay(match.value!.date),
                      match.value!.slot?.label ?? match.value!.timeSlot,
                      match.value!.level.label,
                    ].join(' · '),
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
      ),
      body: AsyncValueView(
        value: match,
        errorText: 'Non riesco a caricare la partita',
        onRetry: () => ref.invalidate(matchDetailProvider(matchId)),
        data: (m) => RefreshIndicator(
          onRefresh: () => ref.refresh(matchDetailProvider(matchId).future),
          child: _Body(match: m),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.match});

  final PadelMatch match;

  Future<void> _show(BuildContext context, String? error, String ok) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error ?? ok)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authControllerProvider).value?.id ?? '';
    final actions = ref.read(matchActionsProvider);
    final organizer = match.isOrganizer(me);
    final participant = match.isParticipant(me);
    final open = match.status == MatchStatus.open;
    final colors = context.colors;
    final theme = Theme.of(context);

    final children = <Widget>[
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Pill(
            text: match.statusLabel,
            background: open
                ? Color.alphaBlend(
                    colors.matchOpen.withValues(alpha: 0.12),
                    colors.surface,
                  )
                : colors.divider,
            foreground: open ? colors.matchOpen : colors.textSecondary,
          ),
          if (organizer)
            _Pill(
              text: 'Organizzi tu',
              background: colors.navy,
              foreground: colors.onNavy,
            ),
        ],
      ),
      const SizedBox(height: 16),
      _Teams(match: match, me: me),
    ];

    if (match.status == MatchStatus.completed &&
        (match.scoreTeam1?.isNotEmpty ?? false)) {
      children.addAll([
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(child: Text('Risultato')),
                Text(
                  match.scoreTeam1!,
                  style: context.fonts.monoStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    if (match.status == MatchStatus.notPlayed) {
      children.addAll([
        const SizedBox(height: 16),
        Text(
          'Partita non disputata: per giocare servono 4 giocatori con il '
          'pagamento registrato in segreteria.',
          style: TextStyle(color: colors.textSecondary),
        ),
      ]);
    }

    // Azioni.
    final buttons = <Widget>[];
    if (organizer && open && match.teamWithFreeSpot != null) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showPlayerPicker(
              context,
              excluded: {
                for (final p in match.players)
                  if (p.clubPlayerId != null) p.clubPlayerId!,
              },
            );
            if (picked == null || !context.mounted) return;
            final error = await actions.addPlayer(match, picked);
            if (context.mounted) {
              await _show(context, error, '${picked.fullName} aggiunto');
            }
          },
          icon: const Icon(Icons.person_add_alt),
          label: const Text('Aggiungi giocatore'),
        ),
      );
    }
    if (organizer &&
        (match.status == MatchStatus.pendingResult ||
            match.status == MatchStatus.inProgress)) {
      buttons.add(
        ElevatedButton(
          onPressed: () async {
            final score = await showResultSheet(context);
            if (score == null || !context.mounted) return;
            final error = await actions.submitResult(match.id, score);
            if (context.mounted) {
              await _show(context, error, 'Risultato salvato');
            }
          },
          child: const Text('Inserisci risultato'),
        ),
      );
    }
    if (!organizer && participant && open) {
      buttons.add(
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: colors.primaryText),
          onPressed: () async {
            final confirmed = await _confirm(
              context,
              title: 'Abbandonare la partita?',
              body: 'Il tuo posto tornerà libero per altri giocatori.',
              action: 'Abbandona',
            );
            if (!confirmed || !context.mounted) return;
            final error = await actions.leave(match.id);
            if (context.mounted) {
              await _show(context, error, 'Hai lasciato la partita');
            }
          },
          child: const Text('Abbandona partita'),
        ),
      );
    }
    if (!organizer && !participant && match.hasFreeSpots) {
      // Si entra direttamente, senza approvazione. Con posto in entrambe le
      // squadre si sceglie dove giocare.
      final teams = [
        if (match.teamA.length < 2) 'A',
        if (match.teamB.length < 2) 'B',
      ];
      for (final team in teams) {
        buttons.add(
          ElevatedButton(
            onPressed: () async {
              final error = await actions.join(match, team: team);
              if (context.mounted) {
                await _show(context, error, 'Sei nella squadra $team');
              }
            },
            child: Text(
              teams.length == 1 ? 'Partecipa' : 'Partecipa in squadra $team',
            ),
          ),
        );
      }
    }
    if (organizer && open) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () async {
            final confirmed = await _confirm(
              context,
              title: 'Annullare la partita?',
              body:
                  'La partita verrà annullata. La prenotazione del campo '
                  'resterà attiva.',
              action: 'Annulla partita',
            );
            if (!confirmed || !context.mounted) return;
            final error = await actions.cancel(match.id);
            if (!context.mounted) return;
            await _show(context, error, 'Partita annullata');
            if (error == null && context.mounted) context.pop();
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Annulla partita'),
        ),
      );
    }
    if (organizer && open && match.bookingId != null) {
      buttons.add(
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colors.primaryText),
          onPressed: () async {
            final done = await confirmAndCancelBooking(
              context,
              ref,
              bookingId: match.bookingId!,
              date: match.date,
              description:
                  '${match.courtName} · ${Dates.shortDay(match.date)} · '
                  '${match.slot?.label ?? match.timeSlot}',
              hasOpenMatch: true,
            );
            if (done && context.mounted) context.pop();
          },
          child: const Text('Annulla prenotazione e partita'),
        ),
      );
    }
    if (buttons.isNotEmpty) {
      children.add(const SizedBox(height: 24));
      for (final b in buttons) {
        children
          ..add(b)
          ..add(const SizedBox(height: 10));
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        ...children,
        if (match.organizerName != null && !organizer) ...[
          const SizedBox(height: 8),
          Text(
            'Organizza ${match.organizerName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
    ),
    // Riga di larghezza minima: il badge non si allarga a tutta la pagina.
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ],
    ),
  );
}

class _Teams extends StatelessWidget {
  const _Teams({required this.match, required this.me});

  final PadelMatch match;
  final String me;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _TeamPanel(
        label: 'SQUADRA A',
        players: match.teamA,
        coefficient: match.teamCoefficient('A'),
        me: me,
        winner: match.winnerTeam == 'team1',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'VS',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      _TeamPanel(
        label: 'SQUADRA B',
        players: match.teamB,
        coefficient: match.teamCoefficient('B'),
        me: me,
        winner: match.winnerTeam == 'team2',
      ),
    ],
  );
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel({
    required this.label,
    required this.players,
    required this.coefficient,
    required this.me,
    required this.winner,
  });

  final String label;
  final List<MatchPlayer> players;
  final double? coefficient;
  final String me;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    MatchPlayer? playerAt(int index) =>
        index < players.length ? players[index] : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (winner) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 16,
                    color: colors.primaryText,
                  ),
                ],
                const Spacer(),
                if (coefficient != null)
                  Text(
                    'Coeff. coppia ${coefficientLabel(coefficient)}',
                    style: context.fonts.monoStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < 2; i++) ...[
              _PlayerRow(player: playerAt(i), me: me, winner: winner),
              if (i == 0) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.me,
    required this.winner,
  });

  final MatchPlayer? player;
  final String me;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = player;
    if (current == null) {
      return Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          'Posto disponibile',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }
    final isMe = current.userId == me && me.isNotEmpty;
    final notes = [
      if (isMe) 'Tu',
      if (current.rankingBandName != null) current.rankingBandName!,
      if (current.playingSide != null) current.playingSide!,
      if (current.participantType != null &&
          current.participantType != 'member')
        'Ospite',
    ];
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? colors.primaryTint : colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      ),
      child: Row(
        children: [
          PlayerRankingMarker(colorHex: current.rankingBandColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  current.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: winner || isMe
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
                if (notes.isNotEmpty)
                  Text(
                    notes.join(' · '),
                    style: TextStyle(color: colors.textSecondary, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
