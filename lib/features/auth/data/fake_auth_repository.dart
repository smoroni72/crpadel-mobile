import 'dart:async';

import '../../../core/network/api_client.dart';
import '../domain/app_user.dart';
import 'auth_repository.dart';

/// Repository in memoria per test e sviluppo senza backend.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.sessionUser, this.password = 'password'});

  static const demoUser = AppUser(
    id: 'user-1',
    email: 'giocatore@example.com',
    fullName: 'Mario Rossi',
    emailVerified: true,
  );

  /// Utente restituito da [restoreSession]; `null` = nessuna sessione.
  AppUser? sessionUser;
  final String password;
  final _sessionExpired = StreamController<void>.broadcast();

  @override
  Stream<void> get sessionExpired => _sessionExpired.stream;

  /// Simula un refresh fallito durante una richiesta.
  void expireSession() {
    sessionUser = null;
    _sessionExpired.add(null);
  }

  @override
  Future<AppUser> restoreSession() async {
    final user = sessionUser;
    if (user == null) {
      throw const ApiException('Sessione scaduta', statusCode: 401);
    }
    return user;
  }

  @override
  Future<AppUser> login(String email, String password) async {
    if (email.trim().toLowerCase() != demoUser.email ||
        password != this.password) {
      throw const ApiException('Credenziali non valide', statusCode: 401);
    }
    return sessionUser = demoUser;
  }

  @override
  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required String gender,
  }) async => 'Registrazione completata. Controlla la tua email.';

  @override
  Future<String> forgotPassword(String email) async =>
      "Se l'indirizzo è registrato riceverai un'email.";

  @override
  Future<void> logout() async => sessionUser = null;
}
