import 'package:crpadel_mobile/features/bookings/data/bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/domain/booking.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fixtures.dart';

Map<String, dynamic> _json(String id, String date, String slot) => {
  'id': id,
  'court_id': 'c2',
  'court_name': 'Campo 2',
  'date': date,
  'time_slot': slot,
  'start_hour': '18.50',
  'end_hour': '20.00',
  'status': 'confirmed',
  'booking_type': 'lesson',
  'coach_name': 'Luca',
  'players': <String>[],
};

void main() {
  test(
    'chiede le prenotazioni confermate dell\'utente e scarta le passate',
    () async {
      final adapter = FakeAdapter(
        (_) => (
          200,
          {
            'data': [
              _json('futura-2', '2026-10-09', '10:00-11:00'),
              _json('futura-1', '2026-10-07', '18:30-20:00'),
              _json('in-corso', '2026-10-07', '11:30-13:00'),
              _json('passata', '2026-10-07', '09:00-10:30'),
            ],
            'meta': {'total': 4},
          },
        ),
      );
      final repository = ApiBookingsRepository(fakeApiClient(adapter));

      final bookings = await repository.upcoming(
        playerEmail: 'mario@example.com',
        now: testNow,
      );

      final request = adapter.requests.single;
      expect(request.path, '/bookings');
      expect(request.queryParameters, {
        'status': 'confirmed',
        'sort': '-date',
        'limit': 100,
        'player_email': 'mario@example.com',
      });
      expect(bookings.map((b) => b.id), ['in-corso', 'futura-1', 'futura-2']);
      expect(bookings.first.bookingType, BookingType.lesson);
      expect(bookings.first.coachName, 'Luca');
      expect(bookings[1].start, DateTime(2026, 10, 7, 18, 30));
    },
  );
}
