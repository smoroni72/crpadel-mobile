import 'package:crpadel_mobile/core/providers.dart';
import 'package:crpadel_mobile/features/auth/data/auth_repository.dart';
import 'package:crpadel_mobile/features/auth/data/fake_auth_repository.dart';
import 'package:crpadel_mobile/features/bookings/data/bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/data/fake_bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/data/preferred_time_repository.dart';
import 'package:crpadel_mobile/features/matches/data/fake_matches_repository.dart';
import 'package:crpadel_mobile/features/matches/data/matches_repository.dart';
import 'package:crpadel_mobile/features/subscriptions/data/fake_subscriptions_repository.dart';
import 'package:crpadel_mobile/features/subscriptions/data/subscriptions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import 'fixtures.dart';

/// Repository fake di un utente già autenticato, con l'ora fissata a
/// [testNow].
class FakeBackend {
  FakeBackend({
    FakeAuthRepository? auth,
    FakeBookingsRepository? bookings,
    FakeMatchesRepository? matches,
    FakeSubscriptionsRepository? subscriptions,
    PreferredTime? preferredTime,
  }) : auth =
           auth ?? FakeAuthRepository(sessionUser: FakeAuthRepository.demoUser),
       bookings = bookings ?? FakeBookingsRepository(),
       matches = matches ?? FakeMatchesRepository(myUserId: myId),
       subscriptions = subscriptions ?? FakeSubscriptionsRepository(),
       preferredTime = InMemoryPreferredTimeRepository(preferredTime);

  final FakeAuthRepository auth;
  final FakeBookingsRepository bookings;
  final FakeMatchesRepository matches;
  final FakeSubscriptionsRepository subscriptions;
  final InMemoryPreferredTimeRepository preferredTime;

  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(auth),
    bookingsRepositoryProvider.overrideWithValue(bookings),
    matchesRepositoryProvider.overrideWithValue(matches),
    subscriptionsRepositoryProvider.overrideWithValue(subscriptions),
    clockProvider.overrideWithValue(() => testNow),
    preferredTimeRepositoryProvider.overrideWithValue(preferredTime),
  ];

  ProviderContainer container() => ProviderContainer(
    overrides: overrides,
    // Nei test un errore deve restare errore, senza nuovi tentativi.
    retry: (_, _) => null,
  );
}
