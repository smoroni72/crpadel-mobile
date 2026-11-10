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
  static const settings = 'impostazioni';
  static const changePassword = 'cambia-password';
  static const subscriptionDetail = 'abbonamento';
  static const notifications = 'notifiche';
  static const exploreMenu = 'menu';
  static const tournaments = 'tornei';
  static const rankings = 'classifiche';
  static const lessons = 'lezioni';
  static const gallery = 'gallery';
  static const crpadelTv = 'crpadel-tv';
  static const clubInfo = 'informazioni-circolo';
  static const admin = 'amministrazione';
  static const adminMatches = 'amministrazione-partite';
  static const adminCreateMatch = 'amministrazione-crea-partita';
  static const adminCompleteMatch = 'amministrazione-completa-partita';
  static const adminBookings = 'amministrazione-prenotazioni';
  static const adminPlayers = 'amministrazione-giocatori';
  static const adminPlayerDetail = 'amministrazione-giocatore';
  static const adminCommunications = 'amministrazione-comunicazioni';
  static const adminMatchHistory = 'amministrazione-storico-partite';
  static const adminUsers = 'amministrazione-utenti';
  static const adminStatistics = 'amministrazione-statistiche';
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
  static const settings = 'impostazioni';
  static const changePassword = 'password';
  static const subscriptionDetail = '/abbonamento/:id';
  static const notifications = '/notifiche';
  static const exploreMenu = '/menu';
  static const tournaments = '/tornei';
  static const rankings = '/classifiche';
  static const lessons = '/lezioni';
  static const gallery = '/gallery';
  static const crpadelTv = '/crpadel-tv';
  static const clubInfo = '/informazioni-circolo';
  static const admin = '/amministrazione';
  static const adminMatches = '/amministrazione/partite';
  static const adminCreateMatch = '/amministrazione/partite/nuova';
  static const adminCompleteMatch = 'completa';
  static const adminBookings = '/amministrazione/prenotazioni';
  static const adminPlayers = '/amministrazione/giocatori';
  static const adminCommunications = '/amministrazione/comunicazioni';
  static const adminMatchHistory = '/amministrazione/storico-partite';
  static const adminUsers = '/amministrazione/utenti';
  static const adminStatistics = '/amministrazione/statistiche';

  /// Percorsi raggiungibili senza aver fatto l'accesso.
  static bool isPublic(String location) => location.startsWith(login);
}
