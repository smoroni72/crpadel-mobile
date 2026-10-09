/// Nomi e percorsi delle route. Si naviga sempre per nome
/// (`context.goNamed(AppRoutes.home)`), mai componendo percorsi a mano.
abstract final class AppRoutes {
  static const splash = 'splash';
  static const chooseClub = 'scegli-circolo';
  static const login = 'login';
  static const register = 'registrazione';
  static const forgotPassword = 'recupero-password';

  static const home = 'home';
  static const book = 'prenota';
  static const freeCourts = 'campi-liberi';
  static const completeBooking = 'completa-prenotazione';
  static const matches = 'partite';
  static const matchDetail = 'partita';
  static const profile = 'profilo';
}

abstract final class AppPaths {
  static const splash = '/splash';
  static const chooseClub = '/scegli-circolo';
  static const login = '/login';
  static const register = 'registrazione';
  static const forgotPassword = 'recupero-password';

  static const home = '/home';
  static const book = '/prenota';
  static const freeCourts = 'liberi';
  static const completeBooking = 'completa';
  static const matches = '/partite';
  static const matchDetail = '/partita/:id';
  static const profile = '/profilo';

  /// Percorsi raggiungibili senza aver fatto l'accesso.
  static bool isPublic(String location) => location.startsWith(login);
}
