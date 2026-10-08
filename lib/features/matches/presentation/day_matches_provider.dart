import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/matches_repository.dart';
import '../domain/padel_match.dart';

/// Giorno mostrato in "Partite del giorno"; parte da oggi e si sposta
/// avanti e indietro senza limiti.
final selectedDayProvider = NotifierProvider<SelectedDayController, DateTime>(
  SelectedDayController.new,
);

class SelectedDayController extends Notifier<DateTime> {
  @override
  DateTime build() => dateOnly(ref.read(clockProvider)());

  void select(DateTime day) => state = dateOnly(day);

  void previous() => state = _shift(-1);

  void next() => state = _shift(1);

  // Costruire la data dai componenti evita gli scarti dell'ora legale.
  DateTime _shift(int days) =>
      DateTime(state.year, state.month, state.day + days);
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Partite del circolo in un giorno, senza quelle annullate.
final dayMatchesProvider = FutureProvider.family<List<PadelMatch>, DateTime>((
  ref,
  day,
) async {
  final matches = await ref.read(matchesRepositoryProvider).byDate(day);
  return matches.where((m) => m.status != MatchStatus.cancelled).toList();
});
