import 'package:intl/intl.dart';

/// Formati di date e orari usati nell'app, tutti in italiano.
///
/// I dati arrivano dall'API nel fuso Europe/Rome e si mostrano così come sono:
/// le date senza orario (`YYYY-MM-DD`) e gli slot (`HH:MM-HH:MM`) non vanno
/// convertiti nel fuso del dispositivo.
abstract final class Dates {
  static const locale = 'it_IT';

  /// "Mercoledì 7 ottobre"
  static String longDay(DateTime date) =>
      _capitalize(DateFormat('EEEE d MMMM', locale).format(date));

  /// "Gio 8 ott"
  static String shortDay(DateTime date) =>
      _capitalize(DateFormat('EEE d MMM', locale).format(date));

  /// "GIO", per i riquadri data delle card.
  static String weekdayBadge(DateTime date) =>
      DateFormat('EEE', locale).format(date).toUpperCase();

  /// "18:30"
  static String time(DateTime time) => DateFormat('HH:mm', locale).format(time);

  /// "18:30–20:00"
  static String timeRange(DateTime start, DateTime end) =>
      '${time(start)}–${time(end)}';

  /// "12/12", per scadenze vicine.
  static String dayMonth(DateTime date) =>
      DateFormat('dd/MM', locale).format(date);

  /// "12/12/2026"
  static String numeric(DateTime date) =>
      DateFormat('dd/MM/yyyy', locale).format(date);

  /// Legge "02/12/2026"; `null` se il testo non è una data esistente.
  static DateTime? parseNumeric(String text) {
    try {
      return DateFormat('dd/MM/yyyy', locale).parseStrict(text.trim());
    } on FormatException {
      return null;
    }
  }

  /// "2026-10-08", il formato delle date nelle query dell'API.
  /// Non dipende dalla lingua: si usa anche prima di caricare i dati locali.
  static String api(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
