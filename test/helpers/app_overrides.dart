import 'package:crpadel_mobile/core/providers.dart';
import 'package:crpadel_mobile/core/push/push_messaging.dart';
import 'package:crpadel_mobile/core/push/push_tokens_repository.dart';
import 'package:crpadel_mobile/core/push/push_preferences.dart';
import 'package:crpadel_mobile/features/auth/data/auth_repository.dart';
import 'package:crpadel_mobile/features/auth/data/fake_auth_repository.dart';
import 'package:crpadel_mobile/features/bookings/data/bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/data/fake_bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/data/preferred_time_repository.dart';
import 'package:crpadel_mobile/features/matches/data/fake_matches_repository.dart';
import 'package:crpadel_mobile/features/home/data/fake_home_repository.dart';
import 'package:crpadel_mobile/features/home/data/home_repository.dart';
import 'package:crpadel_mobile/features/matches/data/matches_repository.dart';
import 'package:crpadel_mobile/features/profile/data/fake_profile_repository.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/subscriptions/data/subscription_details_repository.dart';
import 'package:crpadel_mobile/features/auth/data/account_deletion_repository.dart';
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
    FakeProfileRepository? profile,
    FakeHomeRepository? home,
    this.subscriptionDetails,
    this.accountDeletion,
    this.push,
    this.pushTokens,
    InMemoryPushPreferences? pushPreferences,
  }) : auth =
           auth ?? FakeAuthRepository(sessionUser: FakeAuthRepository.demoUser),
       bookings = bookings ?? FakeBookingsRepository(),
       matches = matches ?? FakeMatchesRepository(myUserId: myId),
       subscriptions = subscriptions ?? FakeSubscriptionsRepository(),
       preferredTime = InMemoryPreferredTimeRepository(preferredTime),
       profile = profile ?? FakeProfileRepository(),
       home = home ?? FakeHomeRepository(),
       pushPreferences = pushPreferences ?? InMemoryPushPreferences();

  final FakeAuthRepository auth;
  final FakeBookingsRepository bookings;
  final FakeMatchesRepository matches;
  final FakeSubscriptionsRepository subscriptions;
  final InMemoryPreferredTimeRepository preferredTime;
  final FakeProfileRepository profile;
  final FakeHomeRepository home;

  /// `null` = dettagli del pacchetto non disponibili (lacuna n. 2).
  final SubscriptionDetailsRepository? subscriptionDetails;

  /// `null` = eliminazione dell'account non disponibile (lacuna n. 10).
  final FakeAccountDeletionRepository? accountDeletion;

  /// `null` = Firebase non configurato.
  final FakePushMessaging? push;
  final FakePushTokensRepository? pushTokens;
  final InMemoryPushPreferences pushPreferences;

  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(auth),
    bookingsRepositoryProvider.overrideWithValue(bookings),
    matchesRepositoryProvider.overrideWithValue(matches),
    subscriptionsRepositoryProvider.overrideWithValue(subscriptions),
    clockProvider.overrideWithValue(() => testNow),
    preferredTimeRepositoryProvider.overrideWithValue(preferredTime),
    profileRepositoryProvider.overrideWithValue(profile),
    homeRepositoryProvider.overrideWithValue(home),
    subscriptionDetailsRepositoryProvider.overrideWithValue(
      subscriptionDetails,
    ),
    accountDeletionRepositoryProvider.overrideWithValue(accountDeletion),
    pushMessagingProvider.overrideWithValue(push),
    pushTokensRepositoryProvider.overrideWithValue(pushTokens),
    pushPreferencesProvider.overrideWithValue(pushPreferences),
  ];

  ProviderContainer container() => ProviderContainer(
    overrides: overrides,
    // Nei test un errore deve restare errore, senza nuovi tentativi.
    retry: (_, _) => null,
  );
}
