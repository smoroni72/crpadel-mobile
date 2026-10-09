import '../domain/directory_player.dart';
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

  /// Rubrica restituita da [playersDirectory].
  List<DirectoryPlayer> directory = const [
    DirectoryPlayer(id: 'p0', fullName: 'Mario Rossi', isSelf: true),
    DirectoryPlayer(id: 'p1', fullName: 'Anna Verdi', rankingBandName: 'Oro'),
    DirectoryPlayer(id: 'p2', fullName: 'Bruno Neri'),
    DirectoryPlayer(id: 'p3', fullName: 'Carla Gialli'),
  ];

  /// Se impostato, solo [create] fallisce con questo errore.
  Object? createError;

  final created = <NewMatch>[];

  @override
  Future<PadelMatch> create(NewMatch request) async {
    if (error != null) throw error!;
    if (createError != null) throw createError!;
    created.add(request);
    final match = PadelMatch(
      id: 'm-${created.length}',
      bookingId: request.bookingId,
      date: DateTime.parse(request.date),
      timeSlot: request.timeSlot,
      organizerRef: myUserId,
      matchType: request.matchType == 'friendly'
          ? MatchType.friendly
          : MatchType.ranking,
      status: MatchStatus.open,
      players: [
        for (final p in request.players)
          MatchPlayer(name: p.fullName, userId: p.isSelf ? myUserId : null),
      ],
    );
    matches = [...matches, match];
    return match;
  }

  @override
  Future<List<DirectoryPlayer>> playersDirectory() async {
    if (error != null) throw error!;
    return directory;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
