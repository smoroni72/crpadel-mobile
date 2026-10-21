import 'package:crpadel_mobile/features/explore/domain/explore_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legge i dati pubblici di un torneo', () {
    final tournament = ClubTournament.fromJson({
      'id': 't1',
      'name': 'Open CRPadel',
      'start_date': '2026-11-05',
      'status': 'upcoming',
      'type': 'americano',
      'level': 'open',
      'registered_players_count': 12,
      'entry_fee': 25,
      'affects_ranking': true,
    });

    expect(tournament.name, 'Open CRPadel');
    expect(tournament.registeredPlayers, 12);
    expect(tournament.entryFee, 25);
    expect(tournament.affectsRanking, isTrue);
  });

  test('legge immagini e didascalie della gallery', () {
    final event = GalleryEvent.fromJson({
      'id': 'g1',
      'title': 'Premiazione',
      'event_date': '2026-10-20',
      'category': 'premiazione',
      'images': [
        {'url': '/api/v1/storage/files/foto.jpg', 'caption': 'Il podio'},
      ],
    });

    expect(event.images.single.caption, 'Il podio');
  });

  test('legge le informazioni del circolo corrente', () {
    final club = ClubInfo.fromJson({
      'name': 'CR Padel',
      'slug': 'crpadel',
      'timezone': 'Europe/Rome',
    });

    expect(club.name, 'CR Padel');
    expect(club.timezone, 'Europe/Rome');
  });
}
