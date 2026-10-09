import 'package:crpadel_mobile/features/bookings/data/bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/domain/booking.dart';
import 'package:crpadel_mobile/features/bookings/domain/booking_request.dart';
import 'package:crpadel_mobile/features/bookings/domain/schedule.dart';
import 'package:crpadel_mobile/features/matches/data/matches_repository.dart';
import 'package:crpadel_mobile/features/matches/domain/directory_player.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  final day = DateTime(2026, 10, 8);

  test('griglia del giorno: orari di apertura e impegni letti', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': {
            'date': '2026-10-08',
            'courts': [
              {'id': 'c1', 'name': 'Campo 1'},
              {'id': 'c2', 'name': 'Campo 2'},
            ],
            'events': [
              {
                'id': 'e1',
                'booking_id': 'b1',
                'court_id': 'c2',
                'source': 'match',
                'kind': 'match',
                'label': 'Mario Rossi',
                'start_hour': 18.5,
                'end_hour': 20,
                'is_owner': true,
                'can_use': true,
              },
              {
                'id': 'e2',
                'booking_id': 'b2',
                'court_id': 'c2',
                'source': 'booking',
                'kind': 'lesson',
                'label': null,
                'start_hour': 17,
                'end_hour': 18,
                'is_owner': false,
                'can_use': false,
              },
            ],
            'rows': <Object>[],
          },
        },
      ),
    );
    final repository = ApiBookingsRepository(fakeApiClient(adapter));

    final grid = await repository.schedule(day);

    expect(adapter.requests.single.path, '/bookings/schedule');
    expect(adapter.requests.single.queryParameters, {
      'date': '2026-10-08',
      'opening_hour': 7,
      'closing_hour': 23,
    });
    expect(grid.courts.map((c) => c.name), ['Campo 1', 'Campo 2']);
    final events = grid.eventsFor('c2');
    expect(events.map((e) => e.kind), [
      ScheduleKind.lesson,
      ScheduleKind.match,
    ]);
    expect(events.last.startMinutes, 18 * 60 + 30);
    expect(events.last.isOwner, isTrue);
    expect(grid.isFree('c2', 20 * 60, 21 * 60 + 30), isTrue);
    expect(grid.isFree('c2', 17 * 60 + 30, 19 * 60), isFalse);
    // Dalle 16:00 restano 60 minuti prima della lezione delle 17.
    expect(grid.freeMinutesFrom('c2', 16 * 60, closingMinutes), 60);
    expect(grid.freeMinutesFrom('c2', 17 * 60 + 30, closingMinutes), 0);
    expect(grid.freeMinutesFrom('c1', 21 * 60, closingMinutes), 120);
  });

  test('campi liberi per orario di inizio', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': {
            'from': '2026-10-08',
            'days': [
              {
                'date': '2026-10-08',
                'slots': [
                  {
                    'time_slot': '19:00-20:30',
                    'start_time': '19:00',
                    'start_hour': 19,
                    'end_hour': 20.5,
                    'available_count': 1,
                    'available_courts': [
                      {'id': 'c1', 'name': 'Campo 1'},
                    ],
                    'courts': <Object>[],
                  },
                ],
              },
            ],
            'slot_minutes': 90,
            'total_courts': 2,
          },
        },
      ),
    );
    final repository = ApiBookingsRepository(fakeApiClient(adapter));

    final slots = await repository.availability(day, slotMinutes: 90);

    expect(adapter.requests.single.queryParameters['slot_minutes'], 90);
    expect(slots.single.startMinutes, 19 * 60);
    expect(slots.single.availableCourts.single.name, 'Campo 1');
  });

  test('prenotare invia campo, fascia e ore decimali', () async {
    final adapter = FakeAdapter(
      (_) => (
        201,
        {
          'data': {
            'id': 'b9',
            'court_id': 'c1',
            'court_name': 'Campo 1',
            'date': '2026-10-08',
            'time_slot': '18:30-19:30',
            'status': 'confirmed',
            'booking_type': 'lesson',
          },
        },
      ),
    );
    final repository = ApiBookingsRepository(fakeApiClient(adapter));

    final booking = await repository.create(
      NewBooking(
        courtId: 'c1',
        date: day,
        startMinutes: 18 * 60 + 30,
        type: BookingType.lesson,
        coachId: 'k1',
      ),
    );

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.data, {
      'court_id': 'c1',
      'date': '2026-10-08',
      'time_slot': '18:30-19:30',
      'start_hour': 18.5,
      'end_hour': 19.5,
      'booking_type': 'lesson',
      'coach_id': 'k1',
    });
    expect(booking.id, 'b9');
  });

  test('annullare usa PATCH con lo stato cancelled', () async {
    final adapter = FakeAdapter((_) => (200, {'data': <String, Object>{}}));
    final repository = ApiBookingsRepository(fakeApiClient(adapter));

    await repository.cancel('b9');

    expect(adapter.requests.single.method, 'PATCH');
    expect(adapter.requests.single.path, '/bookings/b9');
    expect(adapter.requests.single.data, {'status': 'cancelled'});
  });

  test('aprire una partita invia i giocatori per posizione', () async {
    final adapter = FakeAdapter(
      (_) => (
        201,
        {
          'data': {
            'id': 'm1',
            'booking_id': 'b9',
            'date': '2026-10-08',
            'time_slot': '18:30-20:00',
            'status': 'open',
            'match_type': 'friendly',
          },
        },
      ),
    );
    final repository = ApiMatchesRepository(fakeApiClient(adapter));

    await repository.create(
      const NewMatch(
        bookingId: 'b9',
        date: '2026-10-08',
        courtId: 'c1',
        timeSlot: '18:30-20:00',
        matchType: 'friendly',
        players: [DirectoryPlayer(id: 'p1', fullName: 'Anna Verdi')],
      ),
    );

    expect(adapter.requests.single.data, {
      'booking_id': 'b9',
      'date': '2026-10-08',
      'court_id': 'c1',
      'time_slot': '18:30-20:00',
      'match_type': 'friendly',
      'level': 'qualsiasi',
      'max_players': 4,
      'players': [
        {'club_player_id': 'p1', 'name': 'Anna Verdi'},
      ],
    });
  });

  test('rubrica dei giocatori', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': [
            {
              'id': 'p1',
              'full_name': 'Anna Verdi',
              'registration_status': 'member',
              'is_self': false,
              'ranking_band_name': 'Oro',
              'ranking_band_color': '#E8C468',
            },
          ],
        },
      ),
    );
    final repository = ApiMatchesRepository(fakeApiClient(adapter));

    final players = await repository.playersDirectory();

    expect(adapter.requests.single.path, '/players/directory');
    expect(players.single.rankingBandName, 'Oro');
  });
}
