import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bookings/presentation/upcoming_bookings_provider.dart';
import '../data/matches_repository.dart';
import '../domain/directory_player.dart';
import '../domain/padel_match.dart';
import 'day_matches_provider.dart';

/// Giorno mostrato nella tab Partite (indipendente da quello della Home).
final matchesDayProvider = NotifierProvider<SelectedDayController, DateTime>(
  SelectedDayController.new,
);

/// Filtro "Le mie" della tab Partite.
final mineOnlyProvider = NotifierProvider<MineOnlyController, bool>(
  MineOnlyController.new,
);

class MineOnlyController extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// Partite dell'utente da oggi in avanti, dalla più vicina.
final myUpcomingMatchesProvider = FutureProvider<List<PadelMatch>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  final today = dateOnly(ref.read(clockProvider)());
  final matches = await ref
      .read(matchesRepositoryProvider)
      .mine(email: user.email);
  return matches
      .where(
        (m) => m.status != MatchStatus.cancelled && !m.date.isBefore(today),
      )
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
});

final matchDetailProvider = FutureProvider.family<PadelMatch, String>(
  (ref, id) => ref.read(matchesRepositoryProvider).byId(id),
);

final matchActionsProvider = Provider<MatchActions>(MatchActions.new);

/// Azioni su una partita. Ogni metodo restituisce `null` se è andato bene,
/// altrimenti il messaggio da mostrare.
class MatchActions {
  MatchActions(this._ref);
  final Ref _ref;

  MatchesRepository get _matches => _ref.read(matchesRepositoryProvider);

  /// L'utente entra nella partita, in [team] o nella prima squadra con
  /// posto.
  Future<String?> join(PadelMatch match, {String? team}) =>
      _run(match.id, () async {
        final target = team ?? match.teamWithFreeSpot;
        if (target == null) {
          throw const ApiException('La partita è completa', statusCode: 409);
        }
        await _matches.join(match.id, team: target);
      });

  /// L'organizzatore aggiunge un giocatore nella prima squadra con posto.
  Future<String?> addPlayer(PadelMatch match, DirectoryPlayer player) =>
      _run(match.id, () async {
        final team = match.teamWithFreeSpot;
        if (team == null) {
          throw const ApiException('La partita è completa', statusCode: 409);
        }
        await _matches.addParticipant(
          match.id,
          clubPlayerId: player.id,
          team: team,
        );
      });

  Future<String?> leave(String matchId) =>
      _run(matchId, () => _matches.leave(matchId));

  Future<String?> submitResult(String matchId, String score) =>
      _run(matchId, () => _matches.submitResult(matchId, score));

  Future<String?> _run(String matchId, Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Operazione non riuscita. Controlla la connessione.';
    }
    _ref
      ..invalidate(matchDetailProvider(matchId))
      ..invalidate(dayMatchesProvider)
      ..invalidate(myUpcomingMatchesProvider)
      ..invalidate(upcomingBookingsProvider);
    return null;
  }
}
