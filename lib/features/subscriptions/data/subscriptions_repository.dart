import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/player_subscription.dart';

final subscriptionsRepositoryProvider = Provider<SubscriptionsRepository>(
  (ref) => ApiSubscriptionsRepository(ref.watch(apiClientProvider)),
);

abstract interface class SubscriptionsRepository {
  /// Pacchetti e abbonamenti dell'utente, validi in tutti i circoli della
  /// stessa proprietà; dal più recente.
  Future<List<PlayerSubscription>> mine();
}

class ApiSubscriptionsRepository implements SubscriptionsRepository {
  ApiSubscriptionsRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<PlayerSubscription>> mine() async {
    final response = await _api.get('/subscriptions/mine');
    return ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(PlayerSubscription.fromJson)
        .toList();
  }
}
