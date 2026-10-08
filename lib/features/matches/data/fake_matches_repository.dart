import '../domain/padel_match.dart';
import 'matches_repository.dart';

/// Repository in memoria per test e sviluppo senza backend.
class FakeMatchesRepository implements MatchesRepository {
  FakeMatchesRepository({
    this.matches = const [],
    this.myUserId = 'user-1',
    this.error,
  });

  List<PadelMatch> matches;

  /// Utente considerato "me" da [mine].
  final String myUserId;

  /// Se impostato, ogni chiamata fallisce con questo errore.
  Object? error;

  /// Giorni richiesti a [byDate], per verificare i cambi di giorno.
  final requestedDays = <DateTime>[];

  @override
  Future<List<PadelMatch>> byDate(DateTime day) async {
    requestedDays.add(day);
    if (error != null) throw error!;
    return matches.where((m) => _sameDay(m.date, day)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<List<PadelMatch>> mine({required String email}) async {
    if (error != null) throw error!;
    return matches.where((m) => m.involves(myUserId)).toList();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
