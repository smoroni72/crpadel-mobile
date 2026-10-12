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
