import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../bookings/domain/booking.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/padel_match.dart';
import '../../subscriptions/data/subscription_details_repository.dart';
import '../../subscriptions/data/subscriptions_repository.dart';
import '../../subscriptions/domain/player_subscription.dart';
import '../data/profile_repository.dart';
import '../domain/profile_models.dart';

final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const ProfileStats();
  return ref
      .read(profileRepositoryProvider)
      .stats(userId: user.id, email: user.email);
});

final bookingHistoryProvider = FutureProvider<List<Booking>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  return ref.read(profileRepositoryProvider).bookingHistory(email: user.email);
});

final lessonsProvider = FutureProvider<List<Lesson>>(
  (ref) => ref.read(profileRepositoryProvider).lessons(),
);

/// Partite dell'utente (organizzate o giocate), dalle più recenti.
final matchHistoryProvider = FutureProvider<List<PadelMatch>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  final matches = await ref
      .read(matchesRepositoryProvider)
      .mine(email: user.email);
  return (matches.toList()..sort((a, b) => b.start.compareTo(a.start)))
      .take(20)
      .toList();
});

/// Tutti i pacchetti e abbonamenti, anche scaduti: la scheda Abbonamenti
/// compare solo se ce n'è almeno uno.
final allSubscriptionsProvider = FutureProvider<List<PlayerSubscription>>(
  (ref) => ref.read(subscriptionsRepositoryProvider).mine(),
);

/// `null` se il backend non espone ancora i dettagli (lacuna n. 2).
final subscriptionDetailsProvider =
    FutureProvider.family<SubscriptionDetails?, String>((ref, id) async {
      final repository = ref.watch(subscriptionDetailsRepositoryProvider);
      return repository?.details(id);
    });
