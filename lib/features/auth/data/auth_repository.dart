import '../../../core/network/api_client.dart';
import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

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

  Future<AppUser> login(String email, String password) async {
    final response = await _api.post(
      '/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    await _api.setAccessToken(data['access_token'] as String);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

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

  Future<String> forgotPassword(String email) async {
    final response = await _api.post(
      '/auth/forgot-password',
      data: {'email': email.trim().toLowerCase()},
    );
    return (response.data as Map<String, dynamic>)['message'] as String;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      await _api.setAccessToken(null);
    }
  }
}
