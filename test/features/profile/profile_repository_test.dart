import 'package:crpadel_mobile/features/auth/data/auth_repository.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

Map<String, dynamic> _row(
  String ref,
  String name, {
  int played = 0,
  int won = 0,
}) => {
  'player_ref': ref,
  'player_name': name,
  // Con il filtro per giocatore il server risponde sempre 1.
  'position': 1,
  'ranking_band_name': 'Oro',
  'ranking_band_color': '#E8C468',
  'matches_played': played,
  'matches_won': won,
  'elo_score': '1180.50',
};

void main() {
  test('la posizione viene dalla classifica completa', () async {
    final adapter = FakeAdapter((options) {
      if (options.queryParameters.containsKey('player_email')) {
        return (
          200,
          {
            'data': [_row('user-1', 'Mario Rossi', played: 24, won: 15)],
          },
        );
      }
      return (
        200,
        {
          'data': [
            _row('a', 'Primo'),
            _row('b', 'Secondo'),
            _row('user-1', 'Mario Rossi'),
          ],
        },
      );
    });
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    final stats = await repository.stats(
      userId: 'user-1',
      email: 'mario@example.com',
    );

    expect(stats.position, 3);
    expect(stats.matchesPlayed, 24);
    expect(stats.matchesWon, 15);
    expect(stats.winRate, 63);
    expect(stats.bandName, 'Oro');
  });

  test('fuori classifica: nessuna posizione', () async {
    final adapter = FakeAdapter((_) => (200, {'data': <Object>[]}));
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    final stats = await repository.stats(userId: 'user-1', email: 'x@y.it');

    expect(stats.position, isNull);
    expect(stats.winRate, 0);
  });

  test(
    'carica tutte le statistiche personali e calcola la forma recente',
    () async {
      final adapter = FakeAdapter((options) {
        if (options.path == '/players/directory') {
          return (
            200,
            {
              'data': [
                {'id': 'player-1', 'full_name': 'Mario Rossi', 'is_self': true},
              ],
            },
          );
        }
        if (options.path == '/players/player-1/statistics') {
          return (
            200,
            {
              'data': {
                'totals': {
                  'matches_played': 20,
                  'wins': 12,
                  'losses': 8,
                  'undecided': 0,
                  'ranking_matches': 18,
                  'friendly_matches': 2,
                  'tournament_matches': 0,
                  'sets_won': 28,
                  'sets_lost': 19,
                  'games_won': 210,
                  'games_lost': 180,
                  'underdog_matches': 5,
                  'underdog_wins': 3,
                  'favorite_matches': 8,
                  'favorite_wins': 6,
                  'ranking_points_earned': 230.5,
                  'ranking_points_average': 12.81,
                },
                'matches': [
                  {
                    'status': 'completed',
                    'winner_team': 'team1',
                    'position': 0,
                  },
                  {
                    'status': 'completed',
                    'winner_team': 'team2',
                    'position': 0,
                  },
                  {
                    'status': 'completed',
                    'winner_team': 'team2',
                    'position': 2,
                  },
                  {
                    'status': 'completed',
                    'winner_team': 'team1',
                    'position': 0,
                  },
                  {
                    'status': 'completed',
                    'winner_team': 'team1',
                    'position': 2,
                  },
                ],
              },
            },
          );
        }
        if (options.queryParameters.containsKey('player_email')) {
          return (
            200,
            {
              'data': [_row('user-1', 'Mario Rossi', played: 18, won: 11)],
            },
          );
        }
        return (
          200,
          {
            'data': [_row('user-1', 'Mario Rossi')],
          },
        );
      });
      final repository = ApiProfileRepository(fakeApiClient(adapter));

      final stats = await repository.stats(
        userId: 'user-1',
        email: 'mario@example.com',
      );

      expect(stats.matchesPlayed, 20);
      expect(stats.matchesWon, 12);
      expect(stats.matchesLost, 8);
      expect(stats.gamesWon, 210);
      expect(stats.underdogMatches, 5);
      expect(stats.favoriteWins, 6);
      expect(stats.rankingPointsAverage, 12.81);
      expect(stats.recentMatches, 5);
      expect(stats.recentWins, 3);
      expect(stats.recentFormRate, 60);
      expect(stats.formLabel, 'Buona');
      expect(stats.trendLabel, 'Stabile');
    },
  );

  test('classifica mensile: legge soglia, PR e punteggio', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': [
            {
              'position': 1,
              'player_ref': 'p1',
              'player_name': 'Mario Rossi',
              'points_earned': 39.5,
              'monthly_score': 131.67,
              'matches_played': 3,
              'matches_won': 2,
            },
          ],
          'meta': {'month': '2026-10', 'minimum_matches': 3},
        },
      ),
    );
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    final result = await repository.monthlyLeaderboard(month: '2026-10');

    expect(result.month, '2026-10');
    expect(result.minimumMatches, 3);
    expect(result.playerOfTheMonth?.playerName, 'Mario Rossi');
    expect(result.players.single.monthlyScore, 131.67);
    expect(adapter.requests.single.path, '/rankings/monthly');
  });

  test('storico prenotazioni e lezioni dalla più recente', () async {
    final adapter = FakeAdapter((options) {
      if (options.path == '/lessons') {
        return (
          200,
          {
            'data': [
              {
                'id': 'l1',
                'coach_name': 'Luca',
                'date': '2026-10-08',
                'time_slot': '10:00-11:00',
                'status': 'confirmed',
              },
            ],
          },
        );
      }
      return (200, {'data': <Object>[]});
    });
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    await repository.bookingHistory(email: 'mario@example.com');
    final lessons = await repository.lessons();
    await repository.cancelLesson('l1');

    expect(adapter.requests[0].queryParameters, {
      'sort': '-date',
      'limit': 20,
      'player_email': 'mario@example.com',
    });
    expect(lessons.single.status, LessonStatus.confirmed);
    expect(adapter.requests.last.method, 'PATCH');
    expect(adapter.requests.last.path, '/lessons/l1');
    expect(adapter.requests.last.data, {'status': 'cancelled'});
  });

  test('cambio password: invia le due password e chiude la sessione', () async {
    final adapter = FakeAdapter(
      (_) => (200, {'success': true, 'reauthentication_required': true}),
    );
    final api = fakeApiClient(adapter);
    await api.setAccessToken('token');
    final repository = ApiAuthRepository(api);

    await repository.changePassword(
      currentPassword: 'vecchia-password',
      newPassword: 'nuova-password-lunga',
    );

    expect(adapter.requests.single.path, '/auth/change-password');
    expect(adapter.requests.single.data, {
      'current_password': 'vecchia-password',
      'new_password': 'nuova-password-lunga',
    });
  });
}
