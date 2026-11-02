import 'package:crpadel_mobile/features/app_menu/data/app_menu_repository.dart';
import 'package:crpadel_mobile/features/app_menu/domain/app_menu_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  test('legge la configurazione del menu del circolo', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': {
            'home': true,
            'bookings': true,
            'matches': false,
            'profile': true,
            'tournaments': false,
            'rankings': true,
            'lessons': false,
            'gallery': false,
            'notifications': true,
            'club_info': true,
            'create_matches': false,
          },
        },
      ),
    );

    final configuration = await ApiAppMenuRepository(
      fakeApiClient(adapter),
    ).load();

    expect(adapter.requests.single.path, '/tenancy/mobile-menu');
    expect(configuration.home, isTrue);
    expect(configuration.matches, isFalse);
    expect(configuration.rankings, isTrue);
    expect(configuration.clubInfo, isTrue);
    expect(configuration.createMatches, isFalse);
  });

  test('campi non presenti restano attivi per compatibilità', () {
    final configuration = AppMenuConfiguration.fromJson(const {});
    expect(configuration.hasExploreItems, isTrue);
    expect(configuration.bookings, isTrue);
    expect(configuration.createMatches, isTrue);
  });
}
