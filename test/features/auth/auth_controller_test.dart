import 'package:crpadel_mobile/features/auth/data/auth_repository.dart';
import 'package:crpadel_mobile/features/auth/data/fake_auth_repository.dart';
import 'package:crpadel_mobile/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  void createContainer() {
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  }

  test('senza sessione parte da utente nullo', () async {
    repository = FakeAuthRepository();
    createContainer();

    expect(await container.read(authControllerProvider.future), isNull);
  });

  test('ripristina la sessione esistente', () async {
    repository = FakeAuthRepository(sessionUser: FakeAuthRepository.demoUser);
    createContainer();

    expect(
      await container.read(authControllerProvider.future),
      FakeAuthRepository.demoUser,
    );
  });

  test('login riuscito e logout', () async {
    repository = FakeAuthRepository();
    createContainer();
    await container.read(authControllerProvider.future);
    final controller = container.read(authControllerProvider.notifier);

    await controller.login('giocatore@example.com', 'password');
    expect(
      container.read(authControllerProvider).value,
      FakeAuthRepository.demoUser,
    );

    await controller.logout();
    expect(container.read(authControllerProvider).value, isNull);
  });

  test('login con credenziali errate mette lo stato in errore', () async {
    repository = FakeAuthRepository();
    createContainer();
    await container.read(authControllerProvider.future);

    await container
        .read(authControllerProvider.notifier)
        .login('giocatore@example.com', 'sbagliata');

    expect(container.read(authControllerProvider).hasError, isTrue);
  });

  test('sessione scaduta riporta a utente nullo', () async {
    repository = FakeAuthRepository(sessionUser: FakeAuthRepository.demoUser);
    createContainer();
    await container.read(authControllerProvider.future);

    repository.expireSession();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).value, isNull);
  });
}
