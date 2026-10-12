import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../bookings/domain/booking.dart';
import '../domain/profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(ref.watch(apiClientProvider)),
);

abstract interface class ProfileRepository {
  /// Statistiche dell'utente in classifica.
  Future<ProfileStats> stats({required String userId, required String email});

  /// Ultime prenotazioni dell'utente, in ogni stato, dalla più recente.
  Future<List<Booking>> bookingHistory({required String email});

  /// Ultime lezioni dell'utente, dalla più recente.
  Future<List<Lesson>> lessons();

  /// Annulla una propria lezione confermata.
  Future<void> cancelLesson(String lessonId);
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);
  final ApiClient _api;

  /// Il server restituisce al massimo 200 righe di classifica.
  static const _leaderboardLimit = 200;
  static const _historyLimit = 20;

  @override
  Future<ProfileStats> stats({
    required String userId,
    required String email,
  }) async {
    final (mine, board) = await (
      _api.get('/rankings', query: {'player_email': email, 'limit': 1}),
      _api.get(
        '/rankings',
        query: {'sort': 'position', 'limit': _leaderboardLimit},
      ),
    ).wait;
    final own = _list(mine.data).map(PlayerRanking.fromJson).firstOrNull;
    // Con il filtro per giocatore il server calcola la posizione solo sul
    // risultato filtrato (sempre 1): la prendiamo dalla classifica completa,
    // come fa il sito.
    final leaderboard = _list(board.data).map(PlayerRanking.fromJson);
    final index = leaderboard.toList().indexWhere((r) => r.playerRef == userId);
    if (own == null && index < 0) return const ProfileStats();
    return ProfileStats(
      position: index < 0 ? null : index + 1,
      matchesPlayed: own?.matchesPlayed ?? 0,
      matchesWon: own?.matchesWon ?? 0,
      bandName: own?.rankingBandName,
      bandColor: own?.rankingBandColor,
    );
  }

  @override
  Future<List<Booking>> bookingHistory({required String email}) async {
    final response = await _api.get(
      '/bookings',
      query: {'sort': '-date', 'limit': _historyLimit, 'player_email': email},
    );
    return _list(response.data).map(Booking.fromJson).toList();
  }

  @override
  Future<List<Lesson>> lessons() async {
    final response = await _api.get(
      '/lessons',
      query: {'sort': '-date', 'limit': _historyLimit},
    );
    return _list(response.data).map(Lesson.fromJson).toList();
  }

  @override
  Future<void> cancelLesson(String lessonId) async {
    await _api.patch('/lessons/$lessonId', data: {'status': 'cancelled'});
  }
}

List<Map<String, dynamic>> _list(Object? body) =>
    ((body as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
