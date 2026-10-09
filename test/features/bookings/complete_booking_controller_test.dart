import 'package:crpadel_mobile/core/network/api_client.dart';
import 'package:crpadel_mobile/features/auth/presentation/auth_controller.dart';
import 'package:crpadel_mobile/features/bookings/data/preferred_time_repository.dart';
import 'package:crpadel_mobile/features/bookings/domain/booking.dart';
import 'package:crpadel_mobile/features/bookings/domain/schedule.dart';
import 'package:crpadel_mobile/features/bookings/presentation/book_providers.dart';
import 'package:crpadel_mobile/features/bookings/presentation/complete_booking_controller.dart';
import 'package:crpadel_mobile/features/matches/domain/directory_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_overrides.dart';

void main() {
  final day = DateTime(2026, 10, 8);
  const court = CourtRef(id: 'c1', name: 'Campo 1');
  BookingSlot slot({int start = 18 * 60, int free = 120}) => BookingSlot(
    court: court,
    date: day,
    startMinutes: start,
    freeMinutes: free,
  );
  const self = DirectoryPlayer(id: 'p0', fullName: 'Mario Rossi', isSelf: true);
  const anna = DirectoryPlayer(id: 'p1', fullName: 'Anna Verdi');

  late FakeBackend backend;
  late ProviderContainer container;

  setUp(() {
    backend = FakeBackend();
    container = backend.container();
    addTearDown(container.dispose);
  });

  CompleteBookingController controller(BookingSlot s) {
    container.listen(completeBookingProvider(s), (_, _) {});
    return container.read(completeBookingProvider(s).notifier);
  }

  CompleteBookingState state(BookingSlot s) =>
      container.read(completeBookingProvider(s));

  test('parte da Partita, o da Lezione se lo spazio è di 60 minuti', () {
    controller(slot());
    expect(state(slot()).type, BookingType.court);
    controller(slot(free: 60));
    expect(state(slot(free: 60)).type, BookingType.lesson);
  });

  test('lezione e allenamento richiedono l\'istruttore', () {
    final c = controller(slot());
    expect(c.canSubmit, isTrue);
    c.setType(BookingType.training);
    expect(c.canSubmit, isFalse);
    c.setCoach('k1');
    expect(c.canSubmit, isTrue);
  });

  test('un tipo più lungo dello spazio libero non si conferma', () {
    final c = controller(slot(free: 60))..setType(BookingType.court);
    expect(c.fits, isFalse);
    expect(c.canSubmit, isFalse);
  });

  test("«Gioco anch'io» è spento all'inizio e occupa il primo posto", () {
    final s = slot();
    final c = controller(s);
    expect(state(s).playsToo, isFalse);

    c.setPlayer(0, anna);
    c.setPlaysToo(true, self);
    expect(state(s).players, [anna, self, null, null]);

    c.setPlaysToo(false, self);
    expect(state(s).players, [anna, null, null, null]);
  });

  test('lo stesso giocatore non entra due volte', () {
    final s = slot();
    controller(s)
      ..setPlayer(0, anna)
      ..setPlayer(2, anna);
    expect(state(s).playerCount, 1);
  });

  test('conferma: prenotazione a proprio nome e partita aperta', () async {
    await container.read(authControllerProvider.future);
    final s = slot();
    final c = controller(s)
      ..setPlayer(2, anna)
      ..setMatchType('friendly');

    final outcome = await c.submit();

    expect(outcome, isA<BookingConfirmed>());
    final booking = backend.bookings.created.single;
    expect(booking.type, BookingType.court);
    expect(booking.timeSlot, '18:00-19:30');
    final match = backend.matches.created.single;
    expect(match.bookingId, (outcome! as BookingConfirmed).booking.id);
    expect(match.matchType, 'friendly');
    expect(match.players, [anna]);
  });

  test('una lezione non apre una partita', () async {
    final s = slot();
    final c = controller(s)
      ..setType(BookingType.lesson)
      ..setCoach('k2');

    expect(await c.submit(), isA<BookingConfirmed>());
    expect(backend.bookings.created.single.coachId, 'k2');
    expect(backend.matches.created, isEmpty);
  });

  test('spazio occupato nel frattempo: esito di conflitto', () async {
    backend.bookings.conflictOnCreate = true;
    final s = slot();

    final outcome = await controller(s).submit();

    expect(outcome, isA<BookingConflict>());
    expect(backend.bookings.created, isEmpty);
    expect(state(s).submitting, isFalse);
  });

  test('altri errori restano sulla pagina con il messaggio', () async {
    backend.bookings.error = const ApiException(
      'Non puoi prenotare un orario già trascorso',
      statusCode: 400,
    );
    final s = slot();

    final outcome = await controller(s).submit();

    expect(outcome, isNull);
    expect(state(s).error, 'Non puoi prenotare un orario già trascorso');
  });

  test('prenotazione fatta ma partita non aperta', () async {
    backend.matches.createError = const ApiException(
      'La tipologia di partita non è attiva',
      statusCode: 400,
    );

    final outcome = await controller(slot()).submit();

    expect(outcome, isA<MatchNotOpened>());
    expect(
      (outcome! as MatchNotOpened).message,
      'La tipologia di partita non è attiva',
    );
    expect(backend.bookings.created, hasLength(1));
  });

  group('orari e giorno', () {
    test("si prenota dall'ora corrente intera in poi", () {
      final now = DateTime(2026, 10, 7, 13, 13);
      final today = DateTime(2026, 10, 7);
      expect(isBookableStart(today, 13 * 60, now), isTrue);
      expect(isBookableStart(today, 12 * 60 + 30, now), isFalse);
      expect(isBookableStart(DateTime(2026, 10, 8), 8 * 60, now), isTrue);
      expect(isBookableStart(DateTime(2026, 10, 6), 20 * 60, now), isFalse);
    });

    test('il giorno di Prenota non va prima di oggi', () {
      final c = container.read(bookDayProvider.notifier);
      expect(c.canGoBack, isFalse);
      c.previous();
      expect(container.read(bookDayProvider), DateTime(2026, 10, 7));
      c.next();
      expect(c.canGoBack, isTrue);
      c.select(DateTime(2026, 9, 1));
      expect(container.read(bookDayProvider), DateTime(2026, 10, 7));
    });

    test('orario preferito salvato e cancellato', () async {
      expect(await container.read(preferredTimeProvider.future), isNull);
      await container
          .read(preferredTimeProvider.notifier)
          .set(const PreferredTime(19 * 60, 20 * 60));
      expect(backend.preferredTime.value, const PreferredTime(1140, 1200));
      expect(backend.preferredTime.value!.includes(19 * 60 + 30), isTrue);
      await container.read(preferredTimeProvider.notifier).set(null);
      expect(backend.preferredTime.value, isNull);
    });
  });
}
