import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';

/// Eliminazione permanente del proprio account. Nei test il provider può
/// essere sostituito con [FakeAccountDeletionRepository] o con `null`.
final accountDeletionRepositoryProvider = Provider<AccountDeletionRepository?>(
  (ref) => ApiAccountDeletionRepository(ref.watch(apiClientProvider)),
);

abstract interface class AccountDeletionRepository {
  Future<void> deleteAccount({required String password});
}

class ApiAccountDeletionRepository implements AccountDeletionRepository {
  ApiAccountDeletionRepository(this._api);

  final ApiClient _api;

  @override
  Future<void> deleteAccount({required String password}) async {
    await _api.delete('/auth/me', data: {'password': password});
    await _api.setAccessToken(null);
  }
}

class FakeAccountDeletionRepository implements AccountDeletionRepository {
  final deleted = <String>[];

  @override
  Future<void> deleteAccount({required String password}) async =>
      deleted.add(password);
}
