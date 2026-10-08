import 'package:crpadel_mobile/features/auth/presentation/auth_controller.dart';
import 'package:crpadel_mobile/features/bookings/data/fake_bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/presentation/upcoming_bookings_provider.dart';
import 'package:crpadel_mobile/features/matches/data/fake_matches_repository.dart';
import 'package:crpadel_mobile/features/matches/domain/padel_match.dart';
import 'package:crpadel_mobile/features/matches/presentation/day_matches_provider.dart';
import 'package:crpadel_mobile/features/subscriptions/data/fake_subscriptions_repository.dart';
import 'package:crpadel_mobile/features/subscriptions/domain/player_subscription.dart';
import 'package:crpadel_mobile/features/subscriptions/presentation/subscriptions_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_overrides.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('prenotazioni future', () {
    test('collegano la partita aperta sulla prenotazione', () async {
      final backend = FakeBackend(
        bookings: FakeBookingsRepository([
          booking(id: 'b1'),
          booking(id: 'b2', date: DateTime(2026, 10, 9)),
          booking(id: 'passata', date: DateTime(2026, 10, 6)),
        ]),
        matches: FakeMatchesRepository(
          myUserId: myId,
          matches: [
            match(id: 'm1', bookingId: 'b1', organizerRef: myId),
            match(
              id: 'annullata',
              bookingId: 'b2',
              organizerRef: myId,
              status: MatchStatus.cancelled,
            ),
          ],
        ),
      );
      final container = backend.container();
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);

      final items = await container.read(upcomingBookingsProvider.future);

      expect(items.map((i) => i.booking.id), ['b1', 'b2']);
      expect(items[0].match?.id, 'm1');
      expect(items[1].match, isNull);
    });
  });

  group('partite del giorno', () {
    test('parte da oggi e si sposta avanti e indietro', () {
      final container = FakeBackend().container();
      addTearDown(container.dispose);
      final controller = container.read(selectedDayProvider.notifier);

      expect(container.read(selectedDayProvider), DateTime(2026, 10, 7));
      controller.previous();
      controller.previous();
      expect(container.read(selectedDayProvider), DateTime(2026, 10, 5));
      controller.next();
      expect(container.read(selectedDayProvider), DateTime(2026, 10, 6));
      controller.select(DateTime(2026, 11, 1, 15));
      expect(container.read(selectedDayProvider), DateTime(2026, 11, 1));
    });

    test('il passaggio all\'ora solare non salta giorni', () {
      final container = FakeBackend().container();
      addTearDown(container.dispose);
      final controller = container.read(selectedDayProvider.notifier)
        ..select(DateTime(2026, 10, 24));

      controller.next();
      controller.next();
      expect(container.read(selectedDayProvider), DateTime(2026, 10, 26));
    });

    test('escludono le partite annullate', () async {
      final backend = FakeBackend(
        matches: FakeMatchesRepository(
          matches: [
            match(id: 'ok'),
            match(id: 'no', status: MatchStatus.cancelled),
          ],
        ),
      );
      final container = backend.container();
      addTearDown(container.dispose);

      final list = await container.read(
        dayMatchesProvider(DateTime(2026, 10, 7)).future,
      );
      expect(list.map((m) => m.id), ['ok']);
    });
  });

  group('pacchetti', () {
    test('mostra solo quelli utilizzabili, attivi per primi', () async {
      final backend = FakeBackend(
        subscriptions: FakeSubscriptionsRepository([
          package(status: SubscriptionStatus.expired),
          package(status: SubscriptionStatus.pendingActivation),
          package(status: SubscriptionStatus.active),
        ]),
      );
      final container = backend.container();
      addTearDown(container.dispose);

      final list = await container.read(usableSubscriptionsProvider.future);
      expect(list.map((s) => s.status), [
        SubscriptionStatus.active,
        SubscriptionStatus.pendingActivation,
      ]);
    });
  });
}
