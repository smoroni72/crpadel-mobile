import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_repository.dart';
import '../../auth/presentation/auth_controller.dart';

final adminOverviewProvider = FutureProvider<AdminOverview>((ref) {
  final user = ref.watch(authControllerProvider).value!;
  return ref
      .read(adminRepositoryProvider)
      .overview(
        matchesEnabled: user.canAccessAdminMenu('matches'),
        bookingsEnabled: user.canAccessAdminMenu('bookings'),
        playersEnabled: user.canAccessAdminMenu('players'),
      );
});
final adminBookingsProvider = FutureProvider<List<AdminBooking>>(
  (ref) => ref.read(adminRepositoryProvider).bookings(),
);
final adminPlayersProvider = FutureProvider.family<List<AdminPlayer>, String>(
  (ref, search) => ref.read(adminRepositoryProvider).players(search: search),
);
final adminCommunicationsProvider = FutureProvider<List<AdminCommunication>>(
  (ref) => ref.read(adminRepositoryProvider).communications(),
);
