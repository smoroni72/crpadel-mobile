import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/explore_models.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>(
  (ref) => ApiExploreRepository(ref.watch(apiClientProvider)),
);

abstract interface class ExploreRepository {
  Future<List<ClubTournament>> tournaments();
  Future<List<GalleryEvent>> gallery();
  Future<ClubInfo> clubInfo();
}

class ApiExploreRepository implements ExploreRepository {
  ApiExploreRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<ClubTournament>> tournaments() async {
    final response = await _api.get(
      '/tournaments',
      query: {'sort': '-start_date', 'limit': 100},
    );
    return _list(response.data).map(ClubTournament.fromJson).toList();
  }

  @override
  Future<List<GalleryEvent>> gallery() async {
    final response = await _api.get(
      '/gallery-events',
      query: {'is_published': 'true', 'sort': '-event_date', 'limit': 100},
    );
    return _list(response.data).map(GalleryEvent.fromJson).toList();
  }

  @override
  Future<ClubInfo> clubInfo() async {
    final response = await _api.get('/tenancy/current');
    return ClubInfo.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }
}

List<Map<String, dynamic>> _list(Object? body) =>
    ((body as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
