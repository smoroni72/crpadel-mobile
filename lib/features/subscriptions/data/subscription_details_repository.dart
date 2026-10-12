import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_environment.dart';
import '../../profile/domain/profile_models.dart';

/// Fasce, tipi ammessi e movimenti di un pacchetto. Il backend non li espone
/// ancora ai giocatori (lacuna n. 2): esiste solo il fake, attivo con
/// `FAKE_SUBSCRIPTION_DETAILS=true`. Senza, il provider vale `null` e il
/// dettaglio mostra solo i dati reali.
final subscriptionDetailsRepositoryProvider =
    Provider<SubscriptionDetailsRepository?>(
      (ref) => AppEnvironment.fakeSubscriptionDetails
          ? FakeSubscriptionDetailsRepository()
          : null,
    );

abstract interface class SubscriptionDetailsRepository {
  /// Proposta: `windows` e `allowed_match_types` in `/subscriptions/mine`,
  /// `GET /subscriptions/mine/:id/movements`.
  Future<SubscriptionDetails> details(String subscriptionId);
}

class FakeSubscriptionDetailsRepository
    implements SubscriptionDetailsRepository {
  @override
  Future<SubscriptionDetails> details(String subscriptionId) async =>
      SubscriptionDetails(
        windows: [
          for (var day = 1; day <= 5; day++)
            SubscriptionWindow(
              weekday: day,
              startTime: '07:00',
              latestStartTime: '13:00',
            ),
          const SubscriptionWindow(
            weekday: 6,
            startTime: '08:00',
            latestStartTime: '11:00',
          ),
        ],
        allowedMatchTypes: const ['ranking', 'friendly'],
        movements: [
          SubscriptionMovement(
            type: MovementType.purchase,
            date: DateTime(2026, 9, 1),
            delta: 10,
          ),
          SubscriptionMovement(
            type: MovementType.consumption,
            date: DateTime(2026, 9, 12),
            delta: -1,
          ),
          SubscriptionMovement(
            type: MovementType.consumption,
            date: DateTime(2026, 9, 26),
            delta: -1,
          ),
          SubscriptionMovement(
            type: MovementType.reservation,
            date: DateTime(2026, 10, 6),
            delta: -1,
            note: 'Partita di giovedì 8 ottobre',
          ),
        ],
      );
}
