import 'package:crpadel_mobile/features/admin/data/admin_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'legge le statistiche giocatore anche quando PostgreSQL invia stringhe',
    () {
      final player = AdminPlayer.fromJson({
        'id': 'player-1',
        'full_name': 'Mario Rossi',
        'email': 'mario@crpadel.it',
        'ranking_matches_played': '12',
        'ranking_matches_won': '7',
        'ranking_real_points': '1166.67',
        'registration_status': 'member',
      });

      expect(player.matches, 12);
      expect(player.wins, 7);
      expect(player.points, 1166.67);
    },
  );

  test('accetta decimali italiani e conteggi comunicazioni come testo', () {
    final player = AdminPlayer.fromJson({
      'id': 'player-2',
      'ranking_real_points': '13,50',
    });
    final communication = AdminCommunication.fromJson({
      'recipient_count': '42',
    });

    expect(player.points, 13.5);
    expect(communication.recipientCount, 42);
  });

  test('legge i flag utente anche quando arrivano come testo', () {
    final user = AdminUser.fromJson({
      'id': 'user-1',
      'is_active': 'false',
      'email_verified': '1',
    });

    expect(user.active, isFalse);
    expect(user.verified, isTrue);
  });
}
