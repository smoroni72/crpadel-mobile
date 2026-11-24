import '../../../core/network/api_client.dart';

/// Resolve the signed-in player's card through the same account lookup as
/// their profile, including server-side email matching for imported players.
Future<Map<String, dynamic>> loadPlayerCardData(
  ApiClient api, {
  String? playerId,
}) async {
  var id = playerId;
  if (id == null) {
    final response = await api.get('/players/me');
    id = ((response.data as Map)['data'] as Map)['id'] as String?;
  }
  if (id == null || id.isEmpty) {
    throw StateError('Giocatore non disponibile');
  }
  final response = await api.get(
    '/players/$id/statistics',
    query: {'public_view': true, 'include_card': true},
  );
  return Map<String, dynamic>.from((response.data as Map)['data'] as Map);
}
