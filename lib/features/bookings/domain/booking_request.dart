import '../../../core/utils/dates.dart';
import 'booking.dart';

/// Durate fisse per tipo di impegno.
extension BookingTypeDuration on BookingType {
  int get minutes => switch (this) {
    BookingType.court => 90,
    BookingType.lesson => 60,
    BookingType.training => 90,
  };

  bool get needsCoach => this != BookingType.court;

  String get label => switch (this) {
    BookingType.court => 'Partita',
    BookingType.lesson => 'Lezione',
    BookingType.training => 'Allenamento',
  };
}

/// Dati per `POST /bookings`. Si prenota sempre a nome dell'utente.
class NewBooking {
  const NewBooking({
    required this.courtId,
    required this.date,
    required this.startMinutes,
    required this.type,
    this.coachId,
  });

  final String courtId;
  final DateTime date;
  final int startMinutes;
  final BookingType type;
  final String? coachId;

  int get endMinutes => startMinutes + type.minutes;

  /// `"18:30-20:00"`
  String get timeSlot => '${hhmm(startMinutes)}-${hhmm(endMinutes)}';

  Map<String, dynamic> toJson() => {
    'court_id': courtId,
    'date': Dates.api(date),
    'time_slot': timeSlot,
    'start_hour': startMinutes / 60,
    'end_hour': endMinutes / 60,
    'booking_type': type.name,
    if (coachId != null) 'coach_id': coachId,
  };
}

String hhmm(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutes % 60).toString().padLeft(2, '0')}';
