import 'package:crpadel_mobile/features/subscriptions/data/subscriptions_repository.dart';
import 'package:crpadel_mobile/features/subscriptions/domain/player_subscription.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  test('legge pacchetti e abbonamenti dell\'utente', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': [
            {
              'id': 's1',
              'plan_name': 'Mattina 10',
              'plan_type': 'package',
              'status': 'active',
              'activated_at': '2026-09-01T08:00:00.000Z',
              'expires_at': '2026-12-12T22:59:59.000Z',
              'matches_total': 10,
              'matches_reserved': 1,
              'matches_used': 3,
              'matches_available': 6,
              'amount_paid': '120.00',
            },
            {
              'id': 's2',
              'plan_name': 'Open mensile',
              'plan_type': 'unlimited',
              'status': 'pending_activation',
              'activated_at': null,
              'expires_at': null,
              'matches_total': null,
              'matches_reserved': 0,
              'matches_used': 0,
              'matches_available': null,
            },
          ],
        },
      ),
    );
    final repository = ApiSubscriptionsRepository(fakeApiClient(adapter));

    final [package, unlimited] = await repository.mine();

    expect(adapter.requests.single.path, '/subscriptions/mine');
    expect(package.isPackage, isTrue);
    expect(package.matchesAvailable, 6);
    expect(package.expiresAt, DateTime.utc(2026, 12, 12, 22, 59, 59));
    expect(unlimited.status, SubscriptionStatus.pendingActivation);
    expect(unlimited.isPackage, isFalse);
    expect(unlimited.isUsable, isTrue);
  });
}
