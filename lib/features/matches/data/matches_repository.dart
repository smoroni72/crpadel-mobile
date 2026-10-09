import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/dates.dart';
import '../domain/directory_player.dart';
import '../domain/padel_match.dart';

final matchesRepositoryProvider = Provider<MatchesRepository>(
  (ref) => ApiMatchesRepository(ref.watch(apiClientProvider)),
);

abstract interface class MatchesRepository {
  /// Partite del circolo nel giorno indicato, in ordine di orario.
  Future<List<PadelMatch>> byDate(DateTime day);

  /// Partite che l'utente organizza o a cui partecipa, dalle più recenti.
  Future<List<PadelMatch>> mine({required String email});

  /// Apre una partita su una propria prenotazione confermata.
  Future<PadelMatch> create(NewMatch request);

  /// Rubrica dei giocatori del circolo, per aggiungerli a una partita.
  Future<List<DirectoryPlayer>> playersDirectory();

  /// Dettaglio di una partita.
  Future<PadelMatch> byId(String id);

  /// L'organizzatore aggiunge un giocatore della rubrica alla squadra
  /// [team] (`A` o `B`). Solo su partite aperte.
  Future<PadelMatch> addParticipant(
    String matchId, {
    required String clubPlayerId,
    required String team,
  });

  /// L'utente entra in una partita aperta nella squadra [team]. Non serve
  /// l'approvazione di chi l'ha aperta (decisione del 9 ottobre 2026).
  Future<PadelMatch> join(String matchId, {required String team});

  /// Un partecipante (non l'organizzatore) lascia una partita aperta.
  Future<PadelMatch> leave(String matchId);

  /// L'organizzatore inserisce il risultato finale, es. `"6-4 6-3"`.
  Future<PadelMatch> submitResult(String matchId, String score);
}

class ApiMatchesRepository implements MatchesRepository {
  ApiMatchesRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<PadelMatch>> byDate(DateTime day) async {
    final response = await _api.get(
      '/matches',
      query: {'date': Dates.api(day), 'sort': 'date', 'limit': 200},
    );
    return _parse(response.data)..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<List<PadelMatch>> mine({required String email}) async {
    // Per un giocatore l'API usa l'utente autenticato: include anche le
    // partite in cui è solo partecipante.
    final response = await _api.get(
      '/matches',
      query: {'organizer_email': email, 'sort': '-date', 'limit': 100},
    );
    return _parse(response.data);
  }

  @override
  Future<PadelMatch> create(NewMatch request) async {
    final response = await _api.post('/matches', data: request.toJson());
    return PadelMatch.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<DirectoryPlayer>> playersDirectory() async {
    final response = await _api.get('/players/directory');
    return ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(DirectoryPlayer.fromJson)
        .toList();
  }

  @override
  Future<PadelMatch> byId(String id) async =>
      _one((await _api.get('/matches/$id')).data);

  @override
  Future<PadelMatch> addParticipant(
    String matchId, {
    required String clubPlayerId,
    required String team,
  }) async => _one(
    (await _api.post(
      '/matches/$matchId/participants',
      data: {'club_player_id': clubPlayerId, 'team': team},
    )).data,
  );

  @override
  Future<PadelMatch> join(String matchId, {required String team}) async => _one(
    (await _api.post('/matches/$matchId/join', data: {'team': team})).data,
  );

  @override
  Future<PadelMatch> leave(String matchId) async =>
      _one((await _api.post('/matches/$matchId/leave')).data);

  @override
  Future<PadelMatch> submitResult(String matchId, String score) async => _one(
    (await _api.patch(
      '/matches/$matchId',
      // Il sito salva lo stesso punteggio in entrambi i campi.
      data: {'score_team1': score, 'score_team2': score, 'status': 'completed'},
    )).data,
  );

  PadelMatch _one(Object? body) => PadelMatch.fromJson(
    (body as Map<String, dynamic>)['data'] as Map<String, dynamic>,
  );

  List<PadelMatch> _parse(Object? body) =>
      ((body as Map<String, dynamic>)['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(PadelMatch.fromJson)
          .toList();
}
