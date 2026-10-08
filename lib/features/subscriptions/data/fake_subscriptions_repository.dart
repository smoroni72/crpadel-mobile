import '../domain/player_subscription.dart';
import 'subscriptions_repository.dart';

/// Repository in memoria per test e sviluppo senza backend.
class FakeSubscriptionsRepository implements SubscriptionsRepository {
  FakeSubscriptionsRepository([this.subscriptions = const [], this.error]);

  List<PlayerSubscription> subscriptions;

  /// Se impostato, ogni chiamata fallisce con questo errore.
  Object? error;

  @override
  Future<List<PlayerSubscription>> mine() async {
    if (error != null) throw error!;
    return subscriptions;
  }
}
