import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/subscriptions_repository.dart';
import '../domain/player_subscription.dart';

/// Pacchetti e abbonamenti ancora utilizzabili (attivi o da attivare).
/// Lista vuota = la sezione non si mostra.
final usableSubscriptionsProvider = FutureProvider<List<PlayerSubscription>>((
  ref,
) async {
  final all = await ref.read(subscriptionsRepositoryProvider).mine();
  final usable = all.where((s) => s.isUsable).toList()
    ..sort((a, b) {
      // Prima quelli attivi, poi per scadenza più vicina.
      if (a.status != b.status) {
        return a.status == SubscriptionStatus.active ? -1 : 1;
      }
      final aExpiry = a.expiresAt ?? DateTime(9999);
      final bExpiry = b.expiresAt ?? DateTime(9999);
      return aExpiry.compareTo(bExpiry);
    });
  return usable;
});
