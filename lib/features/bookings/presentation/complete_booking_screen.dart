import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../matches/data/match_types_repository.dart';
import '../../matches/domain/directory_player.dart';
import '../domain/booking.dart';
import '../domain/booking_request.dart';
import 'book_providers.dart';
import 'complete_booking_controller.dart';
import 'widgets/player_picker_sheet.dart';

/// Pagina modale a schermo intero: tipo, istruttore, giocatori, conferma.
class CompleteBookingScreen extends ConsumerWidget {
  const CompleteBookingScreen({super.key, required this.slot});

  final BookingSlot slot;

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref
        .read(completeBookingProvider(slot).notifier)
        .submit();
    if (!context.mounted || outcome == null) return;
    switch (outcome) {
      case BookingConfirmed():
        context.goNamed(AppRoutes.home);
        messenger.showSnackBar(
          const SnackBar(content: Text('Prenotazione confermata')),
        );
      case MatchNotOpened(:final message):
        context.goNamed(AppRoutes.home);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Prenotazione confermata, ma la partita non è stata aperta: '
              '$message',
            ),
          ),
        );
      case BookingConflict():
        context.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Lo spazio è stato appena occupato da un altro giocatore. '
              'Scegli un altro orario.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(completeBookingProvider(slot));
    final controller = ref.read(completeBookingProvider(slot).notifier);
    final colors = context.colors;
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final end = slot.startMinutes + state.type.minutes;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        automaticallyImplyLeading: false,
        title: const Text('Completa la prenotazione'),
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            tooltip: 'Chiudi',
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _Label('Tipo di impegno'),
          SegmentedButton<BookingType>(
            showSelectedIcon: false,
            segments: [
              for (final t in BookingType.values)
                ButtonSegment(
                  value: t,
                  // Come nel mockup: la durata dell'allenamento non serve.
                  label: Text(
                    t == BookingType.training
                        ? t.label
                        : "${t.label} · ${t.minutes}'",
                  ),
                ),
            ],
            selected: {state.type},
            onSelectionChanged: (s) => controller.setType(s.first),
          ),
          if (!controller.fits)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Lo spazio libero è di ${slot.freeMinutes} minuti: non basta '
                "per ${state.type.label.toLowerCase()} da ${state.type.minutes}'.",
                style: TextStyle(color: colors.primaryText),
              ),
            ),
          if (state.type.needsCoach) ...[
            const SizedBox(height: 18),
            _CoachField(value: state.coachId, onChanged: controller.setCoach),
          ],
          const SizedBox(height: 18),
          _Summary(
            rows: [
              ('Campo', slot.court.name),
              (
                'Quando',
                '${Dates.shortDay(slot.date)} · '
                    '${hhmm(slot.startMinutes)}–${hhmm(end)}',
              ),
              ('Prenotato da', '${user?.fullName ?? ''} (tu)'),
            ],
          ),
          if (state.type == BookingType.court) ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text('Giocatori', style: theme.textTheme.titleMedium),
                ),
                Text(
                  'facoltativo · ${state.playerCount}/4',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
            _PlaysTooSwitch(
              value: state.playsToo,
              onChanged: controller.setPlaysToo,
            ),
            _TeamsGrid(
              players: state.players,
              onAdd: (position) async {
                final picked = await showPlayerPicker(
                  context,
                  excluded: {
                    for (final p in state.players)
                      if (p != null) p.id,
                  },
                );
                if (picked != null) controller.setPlayer(position, picked);
              },
              onRemove: (position) => controller.setPlayer(position, null),
            ),
            const SizedBox(height: 8),
            Text(
              'Con meno di 4 giocatori la partita resta aperta: chi vuole '
              'giocare invia una richiesta e sei tu ad approvarla.',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 18),
            _Label('Tipo di partita'),
            _MatchTypeChips(
              selected: state.matchType,
              onSelected: controller.setMatchType,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: colors.primaryText),
                  ),
                ),
              ElevatedButton(
                onPressed: controller.canSubmit
                    ? () => _submit(context, ref)
                    : null,
                child: state.submitting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Conferma prenotazione'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
      ),
    ),
  );
}

class _CoachField extends ConsumerWidget {
  const _CoachField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coaches = ref.watch(coachesProvider);
    return coaches.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Row(
        children: [
          const Expanded(child: Text('Non riesco a caricare gli istruttori')),
          TextButton(
            onPressed: () => ref.invalidate(coachesProvider),
            child: const Text('Riprova'),
          ),
        ],
      ),
      data: (list) => DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Istruttore'),
        items: [
          for (final c in list)
            DropdownMenuItem(value: c.id, child: Text(c.name)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: colors.divider)),
              ),
              child: Row(
                children: [
                  Text(
                    rows[i].$1,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaysTooSwitch extends ConsumerWidget {
  const _PlaysTooSwitch({required this.value, required this.onChanged});

  final bool value;
  final void Function(bool, DirectoryPlayer?) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text("Gioco anch'io"),
      value: value,
      onChanged: (v) async {
        DirectoryPlayer? self;
        if (v) {
          final directory = await ref.read(playersDirectoryProvider.future);
          self = directory.where((p) => p.isSelf).firstOrNull;
          if (self == null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Non risulti nella rubrica del circolo'),
              ),
            );
            return;
          }
        }
        onChanged(v, self);
      },
    );
  }
}

class _TeamsGrid extends StatelessWidget {
  const _TeamsGrid({
    required this.players,
    required this.onAdd,
    required this.onRemove,
  });

  final List<DirectoryPlayer?> players;
  final ValueChanged<int> onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final header = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: colors.textSecondary,
    );
    Widget slot(int position) {
      final p = players[position];
      if (p == null) {
        return OutlinedButton(
          onPressed: () => onAdd(position),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: colors.border, width: 1.5),
            foregroundColor: colors.textSecondary,
          ),
          child: const Text('+ Aggiungi'),
        );
      }
      return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: colors.divider,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.navy,
              foregroundColor: colors.onNavy,
              child: Text(
                initials(p.fullName),
                style: const TextStyle(fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                p.isSelf ? 'Tu' : p.fullName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () => onRemove(position),
              tooltip: 'Togli ${p.fullName}',
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      );
    }

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
        for (final row in const [
          [0, 2],
          [1, 3],
        ]) ...[
          Row(
            children: [
              Expanded(child: slot(row[0])),
              const SizedBox(width: 8),
              Expanded(child: slot(row[1])),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MatchTypeChips extends ConsumerWidget {
  const _MatchTypeChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types =
        ref.watch(matchTypesProvider).value ??
        DefaultMatchTypesRepository.defaults;
    final colors = context.colors;
    return Wrap(
      spacing: 8,
      children: [
        for (final t in types)
          ChoiceChip(
            label: Text(t.label),
            selected: t.code == selected,
            onSelected: (_) => onSelected(t.code),
            showCheckmark: false,
            selectedColor: colors.navy,
            labelStyle: TextStyle(
              color: t.code == selected ? colors.onNavy : colors.text,
              fontWeight: FontWeight.w600,
            ),
            shape: const StadiumBorder(),
          ),
      ],
    );
  }
}
