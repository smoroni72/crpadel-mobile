import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AppUser?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AppUser?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.sessionExpired.listen(
      (_) => state = const AsyncData(null),
    );
    ref.onDispose(subscription.cancel);
    try {
      return await repository.restoreSession();
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.login(email, password));
  }

  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required String gender,
  }) => _repository.register(
    email: email,
    password: password,
    fullName: fullName,
    birthDate: birthDate,
    gender: gender,
  );

  Future<String> forgotPassword(String email) =>
      _repository.forgotPassword(email);

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }
}
