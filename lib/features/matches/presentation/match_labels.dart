import '../domain/padel_match.dart';

extension MatchTypeLabel on MatchType {
  String get label => switch (this) {
    MatchType.ranking => 'ranking',
    MatchType.friendly => 'amichevole',
    MatchType.tournament => 'torneo',
    MatchType.other => 'altro',
    MatchType.unknown => 'partita',
  };
}

extension MatchLevelLabel on MatchLevel {
  String get label => switch (this) {
    MatchLevel.principiante => 'principiante',
    MatchLevel.intermedio => 'intermedio',
    MatchLevel.avanzato => 'avanzato',
    MatchLevel.qualsiasi => 'tutti i livelli',
  };
}

extension MatchStatusLabel on PadelMatch {
  /// "3/4"
  String get playersLabel => '${players.length}/$maxPlayers';

  /// Stato breve per le card: "Aperta · 2/4 · intermedio", "In corso"…
  String get statusLabel => switch (status) {
    MatchStatus.open when hasFreeSpots =>
      'Aperta · $playersLabel · ${level.label}',
    MatchStatus.open => 'Al completo · $playersLabel',
    MatchStatus.inProgress => 'In corso',
    MatchStatus.pendingResult => 'In attesa del risultato',
    MatchStatus.completed => 'Conclusa',
    MatchStatus.notPlayed => 'Non disputata',
    MatchStatus.cancelled => 'Annullata',
    MatchStatus.unknown => '',
  };

  /// "Rossi/Bianchi vs Verdi/Neri"
  String get teamsLabel {
    String team(List<MatchPlayer> players) =>
        players.map((p) => p.name.trim().split(' ').last).join('/');
    final a = team(teamA);
    final b = team(teamB);
    if (a.isEmpty && b.isEmpty) return '';
    return '$a vs $b';
  }
}
