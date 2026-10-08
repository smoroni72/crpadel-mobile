/// Fascia oraria nel formato dell'API, `"18:30-20:00"`.
///
/// Gli orari sono quelli del circolo (Europe/Rome) e si combinano con la
/// data della prenotazione così come sono.
class TimeSlot {
  const TimeSlot(this.startMinutes, this.endMinutes);

  /// Minuti dalla mezzanotte.
  final int startMinutes;
  final int endMinutes;

  static final _pattern = RegExp(r'^(\d{2}):(\d{2})-(\d{2}):(\d{2})$');

  static TimeSlot? tryParse(String value) {
    final match = _pattern.firstMatch(value.trim());
    if (match == null) return null;
    int part(int i) => int.parse(match.group(i)!);
    return TimeSlot(part(1) * 60 + part(2), part(3) * 60 + part(4));
  }

  DateTime startOn(DateTime day) =>
      DateTime(day.year, day.month, day.day, 0, startMinutes);

  DateTime endOn(DateTime day) =>
      DateTime(day.year, day.month, day.day, 0, endMinutes);

  /// "18:30"
  String get startLabel => _label(startMinutes);

  /// "18:30–20:00"
  String get label => '${_label(startMinutes)}–${_label(endMinutes)}';

  static String _label(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is TimeSlot &&
      other.startMinutes == startMinutes &&
      other.endMinutes == endMinutes;

  @override
  int get hashCode => Object.hash(startMinutes, endMinutes);
}
