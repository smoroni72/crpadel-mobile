import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crpadel_mobile/core/providers.dart';
import 'package:crpadel_mobile/features/explore/presentation/published_statistics.dart';
import '../../helpers/fake_http.dart';

void main() {
  test('app visibility never falls back to the web channel', () async {
    final adapter = FakeAdapter(
      (o) => (
        200,
        {
          'data': {
            'tiebreaks': {'web': true, 'app': false},
            'final_tiebreaks': {'web': false, 'app': true},
          },
        },
      ),
    );
    final c = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(fakeApiClient(adapter))],
    );
    addTearDown(c.dispose);
    final flags = await c.read(statisticPublicationProvider.future);
    expect(flags['tiebreaks'], false);
    expect(flags['final_tiebreaks'], true);
  });
  test(
    'older servers preserve legacy sections but never enable new reports',
    () async {
      final c = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(
            fakeApiClient(FakeAdapter((o) => (404, {'error': 'Missing'}))),
          ),
        ],
      );
      addTearDown(c.dispose);
      final flags = await c.read(statisticPublicationProvider.future);
      expect(flags['general'], true);
      expect(flags['tiebreaks'], isNull);
    },
  );
  test('podium rules match the admin reports', () {
    Map<String, dynamic> row(String name, int played, int won) => {
      'name': name,
      'played': played,
      'won': won,
      'percentage': 100 * won / played,
    };
    expect(
      statisticPodium([
        row('Diego', 28, 15),
        row('Eliano', 25, 15),
        row('Carlo', 25, 11),
        row('Leo', 17, 12),
      ], 'tiebreaks').map((p) => p['name']),
      ['Eliano', 'Diego', 'Carlo'],
    );
    expect(
      statisticPodium([
        row('Reali', 3, 3),
        row('Fabio', 8, 7),
        row('Leo', 7, 6),
      ], 'final_tiebreaks').map((p) => p['name']),
      ['Fabio', 'Leo'],
    );
  });
  testWidgets('hidden reports do not fetch report data', (tester) async {
    final adapter = FakeAdapter(
      (o) => (
        200,
        {
          'data': {
            'tiebreaks': {'app': false},
            'final_tiebreaks': {'app': false},
            'challenge': {'app': false},
          },
        },
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(fakeApiClient(adapter)),
        ],
        child: const MaterialApp(home: Scaffold(body: PublishedStatistics())),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      adapter.requests.where((r) => r.path.contains('/reports/')),
      isEmpty,
    );
  });
}
