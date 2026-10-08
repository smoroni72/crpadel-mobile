import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/dates.dart';
import '../domain/padel_match.dart';

final matchesRepositoryProvider = Provider<MatchesRepository>(
  (ref) => ApiMatchesRepository(ref.watch(apiClientProvider)),
);

abstract interface class MatchesRepository {
  /// Partite del circolo nel giorno indicato, in ordine di orario.
  Future<List<PadelMatch>> byDate(DateTime day);

  /// Partite che l'utente organizza o a cui partecipa, dalle più recenti.
  Future<List<PadelMatch>> mine({required String email});
}

class ApiMatchesRepository implements MatchesRepository {
  ApiMatchesRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<PadelMatch>> byDate(DateTime day) async {
    final response = await _api.get(
      '/matches',
      query: {'date': Dates.api(day), 'sort': 'date', 'limit': 200},
    );
    return _parse(response.data)..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<List<PadelMatch>> mine({required String email}) async {
    // Per un giocatore l'API usa l'utente autenticato: include anche le
    // partite in cui è solo partecipante.
    final response = await _api.get(
      '/matches',
      query: {'organizer_email': email, 'sort': '-date', 'limit': 100},
    );
    return _parse(response.data);
  }

  List<PadelMatch> _parse(Object? body) =>
      ((body as Map<String, dynamic>)['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(PadelMatch.fromJson)
          .toList();
}
