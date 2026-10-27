import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/config/app_environment.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bookings/presentation/upcoming_bookings_provider.dart';
import '../../bookings/presentation/widgets/booking_card.dart';
import '../../matches/presentation/day_matches_provider.dart';
import '../../matches/presentation/widgets/day_strip.dart';
import '../../matches/presentation/widgets/connected_match_card.dart';
import '../../subscriptions/presentation/subscription_summary_card.dart';
import '../../subscriptions/presentation/subscriptions_provider.dart';
import '../../notifications/presentation/notifications_provider.dart';
import '../../profile/domain/profile_models.dart';
import '../domain/home_news.dart';
import 'home_providers.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    final day = ref.read(selectedDayProvider);
    await Future.wait<Object?>([
      ref.refresh(usableSubscriptionsProvider.future),
      ref.refresh(upcomingBookingsProvider.future),
      ref.refresh(dayMatchesProvider(day).future),
      ref.refresh(homeLeaderboardProvider.future),
      ref.refresh(homeNewsProvider.future),
    ]).catchError((_) => <Object?>[]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(usableSubscriptionsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            children: [
              const _Header(),
              const SizedBox(height: 20),
              // Il riferimento al pacchetto compare solo se ce n'è almeno uno;
              // durante il caricamento o in errore non occupa spazio.
              if (subscriptions.value case [final first, ...final others]) ...[
                SubscriptionSummaryCard(
                  subscription: first,
                  otherCount: others.length,
                ),
                const SizedBox(height: 20),
              ],
              const _RankingSpotlight(),
              const SizedBox(height: 24),
              const _NewsSection(),
              const SizedBox(height: 24),
              const _BookingsSection(),
              const SizedBox(height: 20),
              const _DayMatchesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingSpotlight extends ConsumerWidget {
  const _RankingSpotlight();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranking = ref.watch(homeLeaderboardProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          'I migliori del momento',
          action: TextButton(
            onPressed: () => context.pushNamed(AppRoutes.rankings),
            child: const Text('Vedi classifica'),
          ),
        ),
        Text(
          'Podio e classifica ufficiale del circolo',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
        ),
        const SizedBox(height: 12),
        AsyncValueView(
          value: ranking,
          errorText: 'Non riesco a caricare la classifica',
          onRetry: () => ref.invalidate(homeLeaderboardProvider),
          data: (players) {
            if (players.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'La classifica apparirà dopo le prime partite ranking.',
                  ),
                ),
              );
            }
            final podium = players.take(3).toList();
            return Column(
              children: [
                _PodiumCard(player: podium.first, place: 1, featured: true),
                if (podium.length > 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _PodiumCard(player: podium[1], place: 2)),
                      if (podium.length > 2) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PodiumCard(player: podium[2], place: 3),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Text(
                          'TOP 10 DEL CLUB',
                          style: TextStyle(
                            color: context.colors.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .7,
                          ),
                        ),
                      ),
                      for (final entry in players.take(10).indexed)
                        _RankingRow(
                          player: entry.$2,
                          place: entry.$2.position > 0
                              ? entry.$2.position
                              : entry.$1 + 1,
                          last: entry.$1 == players.take(10).length - 1,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.player,
    required this.place,
    this.featured = false,
  });

  final PlayerRanking player;
  final int place;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = switch (place) {
      1 => const Color(0xFFF2A807),
      2 => const Color(0xFF8490A3),
      _ => const Color(0xFFB96A3D),
    };
    return Container(
      constraints: BoxConstraints(minHeight: featured ? 142 : 164),
      padding: EdgeInsets.all(featured ? 18 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.navy,
            Color.alphaBlend(accent.withValues(alpha: .32), colors.navy),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: .55)),
      ),
      child: featured
          ? Row(
              children: [
                _PlaceBadge(place: place, color: accent, large: true),
                const SizedBox(width: 16),
                Expanded(child: _PodiumDetails(player: player, light: true)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlaceBadge(place: place, color: accent),
                const SizedBox(height: 12),
                _PodiumDetails(player: player, light: true),
              ],
            ),
    );
  }
}

class _PlaceBadge extends StatelessWidget {
  const _PlaceBadge({
    required this.place,
    required this.color,
    this.large = false,
  });
  final int place;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) => Container(
    width: large ? 64 : 42,
    height: large ? 64 : 42,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Text(
      '$place°',
      style: context.fonts
          .monoStyle(fontSize: large ? 22 : 15, fontWeight: FontWeight.w700)
          .copyWith(color: Colors.white),
    ),
  );
}

class _PodiumDetails extends StatelessWidget {
  const _PodiumDetails({required this.player, required this.light});
  final PlayerRanking player;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? Colors.white : context.colors.text;
    final secondary = light ? Colors.white70 : context.colors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: parseHexColor(player.rankingBandColor) ?? secondary,
                border: Border.all(color: Colors.white54),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                player.rankingBandName ?? 'Fascia non assegnata',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          player.playerName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '${_score(player.eloScore)} punti · ${player.matchesWon} vittorie',
          style: TextStyle(fontSize: 11, color: secondary),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.player,
    required this.place,
    required this.last,
  });
  final PlayerRanking player;
  final int place;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$place',
              style: context.fonts.monoStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: parseHexColor(player.rankingBandColor) ?? colors.divider,
              border: Border.all(color: colors.border),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${player.matchesWon} vittorie su ${player.matchesPlayed}',
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            _score(player.eloScore),
            style: context.fonts.monoStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsSection extends ConsumerWidget {
  const _NewsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(homeNewsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader('News & aggiornamenti'),
        AsyncValueView(
          value: news,
          errorText: 'Non riesco a caricare le news',
          onRetry: () => ref.invalidate(homeNewsProvider),
          data: (items) => items.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Nessun aggiornamento pubblicato'),
                  ),
                )
              : Column(
                  children: [
                    for (final item in items) ...[
                      _NewsCard(item: item),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});
  final HomeNews item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imageUrl = _absoluteMediaUrl(item.imageUrl);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showNews(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                height: item.isPinned ? 180 : 130,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.isPinned) ...[
                        Icon(
                          Icons.push_pin_outlined,
                          size: 15,
                          color: colors.primaryText,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryTint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _category(item.category),
                          style: TextStyle(
                            color: colors.primaryText,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (item.publishedDate != null)
                        Text(
                          DateFormat(
                            'd MMM yyyy',
                            'it',
                          ).format(item.publishedDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (item.preview.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.preview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showNews(BuildContext context, HomeNews item) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _category(item.category),
              style: TextStyle(
                color: context.colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            Text(
              item.content.isNotEmpty ? item.content : item.preview,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    ),
  );
}

String _score(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);

String _category(String value) => switch (value) {
  'torneo' => 'TORNEO',
  'evento' => 'EVENTO',
  'promozione' => 'PROMOZIONE',
  'aggiornamento' => 'AGGIORNAMENTO',
  _ => 'GENERALE',
};

String? _absoluteMediaUrl(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri?.hasScheme == true) return value;
  final api = Uri.parse(AppEnvironment.apiBaseUrl);
  return '${api.origin}${value.startsWith('/') ? value : '/$value'}';
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final today = ref.watch(clockProvider)();
    final colors = context.colors;
    final firstName = user?.fullName.trim().split(' ').first ?? '';
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Dates.longDay(today),
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              Text(
                firstName.isEmpty ? 'Ciao' : 'Ciao, $firstName',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        const ThemeToggleButton(),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: () => context.pushNamed(AppRoutes.notifications),
          tooltip: 'Notifiche',
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            side: BorderSide(color: colors.border),
            fixedSize: const Size.square(44),
          ),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 99 ? '99+' : '$unread'),
            child: Icon(Icons.notifications_none, color: colors.text),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: () => context.pushNamed(AppRoutes.exploreMenu),
          tooltip: 'Menu',
          style: IconButton.styleFrom(fixedSize: const Size.square(44)),
          icon: const Icon(Icons.menu),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ?action,
      ],
    ),
  );
}

class _BookingsSection extends ConsumerWidget {
  const _BookingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(upcomingBookingsProvider);
    void goToBook() => context.goNamed(AppRoutes.book);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          'Le tue prenotazioni',
          action: TextButton(onPressed: goToBook, child: const Text('Prenota')),
        ),
        AsyncValueView(
          value: bookings,
          errorText: 'Non riesco a caricare le prenotazioni',
          onRetry: () => ref.invalidate(upcomingBookingsProvider),
          data: (items) => items.isEmpty
              ? _EmptyBookings(onBook: goToBook)
              : Column(
                  children: [
                    for (final item in items) ...[
                      BookingCard(item: item),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, color: context.colors.primary),
          const SizedBox(width: 12),
          const Expanded(child: Text('Nessuna prenotazione in programma')),
          TextButton(onPressed: onBook, child: const Text('Prenota un campo')),
        ],
      ),
    ),
  );
}

class _DayMatchesSection extends ConsumerWidget {
  const _DayMatchesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final dayController = ref.read(selectedDayProvider.notifier);
    final matches = ref.watch(dayMatchesProvider(day));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader('Partite del giorno'),
        DayStrip(
          selected: day,
          onSelected: dayController.select,
          onPrevious: dayController.previous,
          onNext: dayController.next,
        ),
        const SizedBox(height: 10),
        AsyncValueView(
          value: matches,
          errorText: 'Non riesco a caricare le partite',
          onRetry: () => ref.invalidate(dayMatchesProvider(day)),
          data: (list) => list.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'Nessuna partita in programma',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final match in list) ...[
                      ConnectedMatchCard(match: match),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
