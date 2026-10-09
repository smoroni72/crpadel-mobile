import 'package:crpadel_mobile/features/matches/data/matches_repository.dart';
import 'package:crpadel_mobile/features/matches/domain/directory_player.dart';
import 'package:crpadel_mobile/features/matches/domain/padel_match.dart';
import 'package:crpadel_mobile/features/matches/presentation/match_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_overrides.dart';
import '../../helpers/fake_http.dart';
import '../../helpers/fixtures.dart';

Map<String, dynamic> _matchJson() => {
  'id': 'm1',
  'date': '2026-10-08',
  'time_slot': '18:30-20:00',
  'status': 'open',
  'match_type': 'ranking',
  'players': [
    {'user_id': 'user-1', 'name': 'Mario Rossi', 'team': 'B'},
  ],
};

void main() {
  group('API delle partite', () {
    late FakeAdapter adapter;
    late ApiMatchesRepository repository;

    setUp(() {
      adapter = FakeAdapter((_) => (200, {'data': _matchJson()}));
      repository = ApiMatchesRepository(fakeApiClient(adapter));
    });

    test('dettaglio e squadra letta dal campo team', () async {
      final match = await repository.byId('m1');
      expect(adapter.requests.single.path, '/matches/m1');
      expect(match.teamA, isEmpty);
      expect(match.teamB.single.name, 'Mario Rossi');
      expect(match.teamWithFreeSpot, 'A');
    });

    test('aggiungere un giocatore indica la squadra', () async {
      await repository.addParticipant('m1', clubPlayerId: 'p1', team: 'A');
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/matches/m1/participants');
      expect(request.data, {'club_player_id': 'p1', 'team': 'A'});
    });

    test('partecipare indica la squadra', () async {
      await repository.join('m1', team: 'A');
      final request = adapter.requests.single;
      expect(request.path, '/matches/m1/join');
      expect(request.data, {'team': 'A'});
    });

    test('abbandonare', () async {
      await repository.leave('m1');
      expect(adapter.requests.single.path, '/matches/m1/leave');
    });

    test(
      'risultato: stesso punteggio nei due campi e partita conclusa',
      () async {
        await repository.submitResult('m1', '6-4 6-3');
        final request = adapter.requests.single;
        expect(request.method, 'PATCH');
        expect(request.data, {
          'score_team1': '6-4 6-3',
          'score_team2': '6-4 6-3',
          'status': 'completed',
        });
      },
    );
  });

  group('azioni', () {
    late FakeBackend backend;
    late ProviderContainer container;

    setUp(() {
      backend = FakeBackend();
      backend.matches.matches = [
        match(
          id: 'mia',
          organizerRef: myId,
          players: [player('Mario Rossi', userId: myId)],
        ),
        match(id: 'altrui', players: [player('X Y')]),
      ];
      container = backend.container();
      addTearDown(container.dispose);
    });

    MatchActions actions() => container.read(matchActionsProvider);

    test('partecipare senza approvazione, nella squadra con posto', () async {
      final altrui = backend.matches.matches.last;
      expect(await actions().join(altrui), isNull);
      final updated = await container.read(
        matchDetailProvider('altrui').future,
      );
      expect(updated.isParticipant(myId), isTrue);
      expect(updated.players.last.team, 'A');
    });

    test('una partita piena non accetta iscrizioni', () async {
      final piena = match(
        id: 'piena',
        players: [player('A'), player('B'), player('C'), player('D')],
      );
      backend.matches.matches = [...backend.matches.matches, piena];
      expect(await actions().join(piena), 'La partita è completa');
    });

    test('aggiungere un giocatore va nella squadra con posto', () async {
      final mia = backend.matches.matches.first;
      final error = await actions().addPlayer(
        mia,
        const DirectoryPlayer(id: 'p1', fullName: 'Anna Verdi'),
      );
      expect(error, isNull);
      final updated = await container.read(matchDetailProvider('mia').future);
      expect(updated.players.last.team, 'A');
    });

    test('abbandono e risultato aggiornano la partita', () async {
      expect(await actions().leave('altrui'), isNull);
      expect(backend.matches.left, ['altrui']);
      expect(await actions().submitResult('mia', '6-4 6-3'), isNull);
      final mia = await container.read(matchDetailProvider('mia').future);
      expect(mia.status, MatchStatus.completed);
    });
  });
}
