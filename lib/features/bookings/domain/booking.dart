import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/time_slot.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum BookingStatus { confirmed, cancelled, completed, unknown }

enum BookingType { court, lesson, training }

@freezed
abstract class Booking with _$Booking {
  const Booking._();

  const factory Booking({
    required String id,
    String? courtId,
    @Default('') String courtName,

    /// Giorno della prenotazione (solo data, `YYYY-MM-DD`).
    required DateTime date,

    /// `"18:30-20:00"`
    required String timeSlot,
    @JsonKey(unknownEnumValue: BookingStatus.unknown)
    @Default(BookingStatus.unknown)
    BookingStatus status,
    @JsonKey(unknownEnumValue: BookingType.court)
    @Default(BookingType.court)
    BookingType bookingType,
    String? coachName,
    String? playerEmail,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  TimeSlot? get slot => TimeSlot.tryParse(timeSlot);

  DateTime get start => slot?.startOn(date) ?? date;

  DateTime get end => slot?.endOn(date) ?? date;
}
