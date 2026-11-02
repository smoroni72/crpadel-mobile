import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/app_menu_configuration.dart';

final appMenuRepositoryProvider = Provider<AppMenuRepository>(
  (ref) => ApiAppMenuRepository(ref.watch(apiClientProvider)),
);

abstract interface class AppMenuRepository {
  Future<AppMenuConfiguration> load();
}

class ApiAppMenuRepository implements AppMenuRepository {
  ApiAppMenuRepository(this._api);

  final ApiClient _api;

  @override
  Future<AppMenuConfiguration> load() async {
    final response = await _api.get('/tenancy/mobile-menu');
    final body = response.data as Map<String, dynamic>;
    return AppMenuConfiguration.fromJson(body['data'] as Map<String, dynamic>);
  }
}
