import 'package:crpadel_mobile/core/utils/dates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Dates.locale));

  final wednesday = DateTime(2026, 10, 7, 18, 30);

  test('giorno esteso e breve in italiano, con maiuscola', () {
    expect(Dates.longDay(wednesday), 'Mercoledì 7 ottobre');
    expect(Dates.shortDay(DateTime(2026, 10, 8)), 'Gio 8 ott');
    expect(Dates.weekdayBadge(DateTime(2026, 10, 8)), 'GIO');
  });

  test('orari e intervalli', () {
    expect(Dates.time(wednesday), '18:30');
    expect(
      Dates.timeRange(wednesday, wednesday.add(const Duration(minutes: 90))),
      '18:30–20:00',
    );
  });

  test('formati numerico e API', () {
    expect(Dates.numeric(DateTime(2026, 12, 2)), '02/12/2026');
    expect(Dates.api(DateTime(2026, 1, 5)), '2026-01-05');
  });

  test('legge le date gg/mm/aaaa solo se esistono', () {
    expect(Dates.parseNumeric('02/12/1990'), DateTime(1990, 12, 2));
    expect(Dates.parseNumeric('31/02/1990'), isNull);
    expect(Dates.parseNumeric('02/12'), isNull);
    expect(Dates.parseNumeric(''), isNull);
  });
}
