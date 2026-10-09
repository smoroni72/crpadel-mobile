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
          child: const Text('Annulla prenotazione'),
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final header = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: colors.textSecondary,
    );
    Widget slot(MatchPlayer? p) {
      if (p == null) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: colors.border, width: 1.5),
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            'Posto libero',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        );
      }
      final isMe = p.userId == me && me.isNotEmpty;
      final note = [
        if (isMe) 'tu',
        if (p.playingSide != null) p.playingSide!,
        if (p.participantType != null && p.participantType != 'member')
          'ospite',
      ].join(' · ');
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: isMe ? colors.navy : colors.textSecondary,
              foregroundColor: colors.onNavy,
              child: Text(
                initials(p.name),
                style: const TextStyle(fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (note.isNotEmpty)
                    Text(
                      note,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    MatchPlayer? at(List<MatchPlayer> team, int i) =>
        i < team.length ? team[i] : null;
    final a = match.teamA;
    final b = match.teamB;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text('SQUADRA A', style: header)),
            const SizedBox(width: 8),
            Expanded(child: Text('SQUADRA B', style: header)),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < 2; i++) ...[
          Row(
            children: [
              Expanded(child: slot(at(a, i))),
              const SizedBox(width: 8),
              Expanded(child: slot(at(b, i))),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
