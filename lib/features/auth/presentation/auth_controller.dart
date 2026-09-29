import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

final apiClientProvider = FutureProvider<ApiClient>(
  (ref) => ApiClient.create(),
);

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  return AuthRepository(await ref.watch(apiClientProvider.future));
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    try {
      return await (await ref.watch(
        authRepositoryProvider.future,
      )).restoreSession();
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => (await ref.read(
        authRepositoryProvider.future,
      )).login(email, password),
    );
  }

  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required String gender,
  }) async {
    return (await ref.read(authRepositoryProvider.future)).register(
      email: email,
      password: password,
      fullName: fullName,
      birthDate: birthDate,
      gender: gender,
    );
  }

  Future<String> forgotPassword(String email) async {
    return (await ref.read(
      authRepositoryProvider.future,
    )).forgotPassword(email);
  }

  Future<void> logout() async {
    await (await ref.read(authRepositoryProvider.future)).logout();
    state = const AsyncData(null);
  }
}
