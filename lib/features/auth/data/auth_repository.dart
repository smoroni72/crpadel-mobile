import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(ref.watch(apiClientProvider)),
);

abstract interface class AuthRepository {
  /// Recupera l'utente dal cookie di refresh; lancia un errore se non c'è
  /// una sessione valida.
  Future<AppUser> restoreSession();

  Future<AppUser> login(String email, String password);

  /// Restituisce il messaggio del server da mostrare all'utente.
  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required String gender,
  });

  /// Restituisce il messaggio del server da mostrare all'utente.
  Future<String> forgotPassword(String email);

  Future<void> logout();

  /// Emette quando la sessione scade e il refresh non riesce.
  Stream<void> get sessionExpired;
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);
  final ApiClient _api;

  @override
  Stream<void> get sessionExpired => _api.sessionExpired;

  @override
  Future<AppUser> restoreSession() async {
    try {
      await _api.refresh();
    } catch (_) {
      await _api.setAccessToken(null);
      rethrow;
    }
    final response = await _api.get('/auth/me');
    final data = response.data as Map<String, dynamic>;
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AppUser> login(String email, String password) async {
    final response = await _api.post(
      '/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    await _api.setAccessToken(data['access_token'] as String);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required String gender,
  }) async {
    final response = await _api.post(
      '/auth/register',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'full_name': fullName.trim(),
        'birth_date': birthDate.toIso8601String().substring(0, 10),
        'gender': gender,
      },
    );
    return (response.data as Map<String, dynamic>)['message'] as String;
  }

  @override
  Future<String> forgotPassword(String email) async {
    final response = await _api.post(
      '/auth/forgot-password',
      data: {'email': email.trim().toLowerCase()},
    );
    return (response.data as Map<String, dynamic>)['message'] as String;
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      await _api.setAccessToken(null);
    }
  }
}
