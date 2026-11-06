import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../bookings/data/bookings_repository.dart';
import '../../bookings/domain/booking_request.dart';
import '../../bookings/domain/schedule.dart';
import '../../bookings/presentation/widgets/player_picker_sheet.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/directory_player.dart';
import '../../matches/domain/padel_match.dart';
import '../../matches/presentation/day_matches_provider.dart';
import '../../matches/presentation/match_providers.dart';

final _editMatchCourtsProvider = FutureProvider.autoDispose<List<CourtRef>>(
  (ref) async => [
    for (final court in await ref.read(bookingsRepositoryProvider).courts())
      CourtRef(id: court.id, name: court.name),
  ],
);

class AdminEditMatchScreen extends ConsumerStatefulWidget {
  const AdminEditMatchScreen({super.key, required this.match});

  final PadelMatch match;

  @override
  ConsumerState<AdminEditMatchScreen> createState() =>
      _AdminEditMatchScreenState();
}

class _AdminEditMatchScreenState extends ConsumerState<AdminEditMatchScreen> {
  late DateTime _date;
  late int _startMinutes;
  String? _courtId;
  late List<MatchPlayer?> _players;
  var _playersChanged = false;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _date = DateTime(
      widget.match.date.year,
      widget.match.date.month,
      widget.match.date.day,
    );
    _startMinutes = widget.match.slot?.startMinutes ?? 8 * 60;
    _courtId = widget.match.courtId;
    _players = <MatchPlayer?>[
      ...widget.match.teamA.take(2),
      ...List<MatchPlayer?>.filled(
        (2 - widget.match.teamA.length).clamp(0, 2).toInt(),
        null,
      ),
      ...widget.match.teamB.take(2),
      ...List<MatchPlayer?>.filled(
        (2 - widget.match.teamB.length).clamp(0, 2).toInt(),
        null,
      ),
    ];
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      locale: const Locale('it', 'IT'),
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _pickPlayer(int index) async {
    final picked = await showPlayerPicker(
      context,
      excluded: {
        for (final player in _players)
          if (player?.clubPlayerId != null) player!.clubPlayerId!,
      },
    );
    if (picked == null) return;
    setState(() {
      _players[index] = MatchPlayer(
        clubPlayerId: picked.id,
        name: picked.fullName,
        team: index < 2 ? 'A' : 'B',
      );
      _playersChanged = true;
    });
  }

  Future<void> _save() async {
    final courtId = _courtId;
    if (courtId == null) {
      setState(() => _error = 'Seleziona il campo');
      return;
    }
    if (_playersChanged && _players.whereType<MatchPlayer>().length != 4) {
      setState(() => _error = 'Seleziona tutti e quattro i giocatori');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(matchesRepositoryProvider)
          .update(
            widget.match.id,
            UpdateMatch(
              date: Dates.api(_date),
              courtId: courtId,
              timeSlot: '${hhmm(_startMinutes)}-${hhmm(_startMinutes + 90)}',
              players: _playersChanged
                  ? _players.whereType<MatchPlayer>().toList()
                  : null,
            ),
          );
      _refresh();
      if (mounted) Navigator.pop(context, false);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Modifica non riuscita. Riprova.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminare la partita?'),
        content: const Text(
          'La partita verrà eliminata definitivamente. Se ha prodotto punti, '
          'il server ricalcolerà la classifica dalle partite successive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(matchesRepositoryProvider).delete(widget.match.id);
      _refresh();
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Eliminazione non riuscita.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _refresh() {
    ref
      ..invalidate(matchDetailProvider(widget.match.id))
      ..invalidate(dayMatchesProvider)
      ..invalidate(matchDatesProvider)
      ..invalidate(myMatchesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final courts = ref.watch(_editMatchCourtsProvider);
    const canEditPlayers = true;
    final starts = [
      for (var value = 8 * 60; value <= 22 * 60; value += 30) value,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Modifica partita')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          InkWell(
            onTap: _saving ? null : _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(Dates.numeric(_date)),
            ),
          ),
          const SizedBox(height: 12),
          courts.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Impossibile caricare i campi'),
            data: (items) {
              _courtId ??= items
                  .where((court) => court.name == widget.match.courtName)
                  .firstOrNull
                  ?.id;
              return DropdownButtonFormField<String>(
                initialValue: _courtId,
                decoration: const InputDecoration(labelText: 'Campo'),
                items: [
                  for (final court in items)
                    DropdownMenuItem(value: court.id, child: Text(court.name)),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _courtId = value),
              );
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _startMinutes,
            decoration: const InputDecoration(labelText: 'Orario'),
            items: [
              for (final start in starts)
                DropdownMenuItem(
                  value: start,
                  child: Text('${hhmm(start)} – ${hhmm(start + 90)}'),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _startMinutes = value!),
          ),
          const SizedBox(height: 22),
          Text('Giocatori', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var index = 0; index < 4; index++) ...[
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(index < 2 ? 'A' : 'B')),
                title: Text(_players[index]?.name ?? 'Posto libero'),
                subtitle: Text('Squadra ${index < 2 ? 'A' : 'B'}'),
                onTap: canEditPlayers && !_saving
                    ? () => _pickPlayer(index)
                    : null,
                trailing: _players[index] != null && canEditPlayers
                    ? IconButton(
                        tooltip: 'Rimuovi giocatore',
                        onPressed: _saving
                            ? null
                            : () => setState(() {
                                _players[index] = null;
                                _playersChanged = true;
                              }),
                        icon: const Icon(Icons.close),
                      )
                    : const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: context.colors.primary)),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _saving || courts.value == null ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Salvataggio…' : 'Salva modifiche'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.primary,
            ),
            onPressed: _saving ? null : _delete,
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Elimina definitivamente'),
          ),
        ],
      ),
    );
  }
}
