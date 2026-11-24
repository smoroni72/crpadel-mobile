import 'package:crpadel_mobile/features/profile/data/player_card_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/fake_http.dart';

void main() {
  test(
    'personal PDF uses account lookup instead of directory is_self',
    () async {
      final adapter = FakeAdapter(
        (request) => switch (request.path) {
          '/players/me' => (
            200,
            {
              'data': {'id': 'own-player'},
            },
          ),
          '/players/own-player/statistics' => (
            200,
            {
              'data': {
                'card': {'name': 'Own'},
              },
            },
          ),
          _ => (404, {'error': 'Unexpected request'}),
        },
      );
      final data = await loadPlayerCardData(fakeApiClient(adapter));
      expect(data['card'], {'name': 'Own'});
      expect(adapter.requests.map((r) => r.path), [
        '/players/me',
        '/players/own-player/statistics',
      ]);
      expect(adapter.requests.last.queryParameters, {
        'public_view': true,
        'include_card': true,
      });
    },
  );

  test('another player PDF never substitutes the signed-in player', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': {'card': 'other'},
        },
      ),
    );
    final data = await loadPlayerCardData(
      fakeApiClient(adapter),
      playerId: 'other-player',
    );
    expect(data['card'], 'other');
    expect(adapter.requests.single.path, '/players/other-player/statistics');
  });

  test('an unlinked account never opens a different player card', () async {
    final adapter = FakeAdapter((_) => (200, {'data': <String, Object?>{}}));
    await expectLater(
      loadPlayerCardData(fakeApiClient(adapter)),
      throwsStateError,
    );
    expect(adapter.requests.single.path, '/players/me');
  });
}
