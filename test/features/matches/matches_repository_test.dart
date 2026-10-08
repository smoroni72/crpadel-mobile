import 'package:crpadel_mobile/features/matches/data/matches_repository.dart';
import 'package:crpadel_mobile/features/matches/domain/padel_match.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  final matchJson = {
    'id': 'm1',
    'booking_id': 'b1',
    'date': '2026-10-07',
    'court_id': 'c3',
    'court_name': 'Campo 3',
    'time_slot': '19:00-20:30',
    'start_time': '19:00',
    'end_time': '20:30',
    'status': 'pending_result',
    'match_type': 'friendly',
    'level': 'avanzato',
    'organizer_ref': 'user-1',
    'organizer_name': 'Mario Rossi',
    'max_players': 4,
    'score_team1': null,
    'score_team2': null,
    'winner_team': null,
    'players': [
      {
        'club_player_id': 'cp1',
        'user_id': 'user-1',
        'player_ref': 'user-1',
        'name': 'Mario Rossi',
        'participant_type': 'member',
      },
      {
        'club_player_id': null,
        'user_id': null,
        'player_ref': 'abc',
        'name': 'Ospite',
        'participant_type': 'anonymous_guest',
      },
    ],
  };

  test('partite del giorno: data nella query e campi letti', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': [matchJson],
        },
      ),
    );
    final repository = ApiMatchesRepository(fakeApiClient(adapter));

    final matches = await repository.byDate(DateTime(2026, 10, 7));

    expect(adapter.requests.single.queryParameters, {
      'date': '2026-10-07',
      'sort': 'date',
      'limit': 200,
    });
    final match = matches.single;
    expect(match.status, MatchStatus.pendingResult);
    expect(match.matchType, MatchType.friendly);
    expect(match.level, MatchLevel.avanzato);
    expect(match.players, hasLength(2));
    expect(match.involves('user-1'), isTrue);
    expect(match.involves('user-2'), isFalse);
  });

  test('uno stato sconosciuto non rompe la lettura', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': [
            {...matchJson, 'status': 'nuovo_stato', 'match_type': 'boh'},
          ],
        },
      ),
    );
    final repository = ApiMatchesRepository(fakeApiClient(adapter));

    final match = (await repository.byDate(DateTime(2026, 10, 7))).single;

    expect(match.status, MatchStatus.unknown);
    expect(match.matchType, MatchType.unknown);
  });

  test('le mie partite usano il filtro organizzatore', () async {
    final adapter = FakeAdapter((_) => (200, {'data': []}));
    final repository = ApiMatchesRepository(fakeApiClient(adapter));

    await repository.mine(email: 'mario@example.com');

    expect(
      adapter.requests.single.queryParameters['organizer_email'],
      'mario@example.com',
    );
  });
}
