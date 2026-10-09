import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../matches/data/match_types_repository.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/directory_player.dart';
import '../../matches/presentation/day_matches_provider.dart';
import '../data/bookings_repository.dart';
import '../data/preferred_time_repository.dart';
import '../domain/coach.dart';
import '../domain/schedule.dart';

/// Giorno mostrato in Prenota: da oggi in avanti.
final bookDayProvider = NotifierProvider<BookDayController, DateTime>(
  BookDayController.new,
);

class BookDayController extends Notifier<DateTime> {
  DateTime get _today => dateOnly(ref.read(clockProvider)());

  @override
  DateTime build() => _today;

  bool get canGoBack => state.isAfter(_today);

  void previous() {
    if (canGoBack) state = DateTime(state.year, state.month, state.day - 1);
  }

  void next() => state = DateTime(state.year, state.month, state.day + 1);

  void select(DateTime day) {
    final value = dateOnly(day);
    state = value.isBefore(_today) ? _today : value;
  }
}

/// Indice del campo mostrato nella griglia.
final selectedCourtProvider = NotifierProvider<SelectedCourtController, int>(
  SelectedCourtController.new,
);

class SelectedCourtController extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final scheduleProvider = FutureProvider.family<DaySchedule, DateTime>(
  (ref, day) => ref.read(bookingsRepositoryProvider).schedule(day),
);

/// Orari di inizio con campi liberi per una durata in minuti.
final availabilityProvider =
    FutureProvider.family<List<AvailabilitySlot>, (DateTime, int)>(
      (ref, args) => ref
          .read(bookingsRepositoryProvider)
          .availability(args.$1, slotMinutes: args.$2),
    );

/// Dettagli dei campi (tipo, superficie) per id.
final courtDetailsProvider = FutureProvider<Map<String, Court>>((ref) async {
  final courts = await ref.read(bookingsRepositoryProvider).courts();
  return {for (final c in courts) c.id: c};
});

final coachesProvider = FutureProvider<List<Coach>>((ref) async {
  final coaches = await ref.read(bookingsRepositoryProvider).coaches();
  return coaches.where((c) => c.isActive).toList();
});

final playersDirectoryProvider = FutureProvider<List<DirectoryPlayer>>(
  (ref) => ref.read(matchesRepositoryProvider).playersDirectory(),
);

final matchTypesProvider = FutureProvider<List<MatchTypeOption>>(
  (ref) => ref.read(matchTypesRepositoryProvider).activeTypes(),
);

final preferredTimeProvider =
    AsyncNotifierProvider<PreferredTimeController, PreferredTime?>(
      PreferredTimeController.new,
    );

class PreferredTimeController extends AsyncNotifier<PreferredTime?> {
  @override
  Future<PreferredTime?> build() =>
      ref.read(preferredTimeRepositoryProvider).load();

  Future<void> set(PreferredTime? value) async {
    await ref.read(preferredTimeRepositoryProvider).save(value);
    state = AsyncData(value);
  }
}

/// Regola del server: si prenota dall'ora corrente intera in poi
/// (alle 13:13 va bene un inizio alle 13:00, non alle 12:30).
bool isBookableStart(DateTime day, int startMinutes, DateTime now) {
  final today = dateOnly(now);
  final d = dateOnly(day);
  if (d.isBefore(today)) return false;
  if (d.isAfter(today)) return true;
  return startMinutes >= now.hour * 60;
}
