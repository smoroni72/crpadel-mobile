import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/home_news.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => ApiHomeRepository(ref.watch(apiClientProvider)),
);

abstract interface class HomeRepository {
  Future<List<HomeNews>> news({int limit = 6});
}

class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<HomeNews>> news({int limit = 6}) async {
    final response = await _api.get(
      '/news',
      query: {
        'is_published': 'true',
        'sort': '-published_date',
        'limit': limit,
      },
    );
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(HomeNews.fromJson)
        .toList();
  }
}
