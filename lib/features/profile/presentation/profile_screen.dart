import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bookings/domain/booking.dart';
import '../../bookings/presentation/book_providers.dart';
import '../../bookings/presentation/cancel_booking.dart';
import '../../subscriptions/domain/player_subscription.dart';
import '../../notifications/presentation/notifications_provider.dart';
import '../data/profile_repository.dart';
import '../domain/profile_models.dart';
import 'delete_account.dart';
import 'profile_labels.dart';
import 'profile_providers.dart';
import 'widgets/player_mood_avatar.dart';

/// Profilo uguale a quello del sito: card, 4 riquadri, schede, Esci ed
/// Elimina account. Le voci solo dell'app sono in Impostazioni.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

enum _Tab { bookings, matches, lessons, subscriptions }

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  var _tab = _Tab.bookings;

  Future<void> _refresh() async {
    await Future.wait<Object?>([
      ref.refresh(profileStatsProvider.future),
      ref.refresh(bookingHistoryProvider.future),
      ref.refresh(matchHistoryProvider.future),
      ref.refresh(lessonsProvider.future),
      ref.refresh(allSubscriptionsProvider.future),
    ]).catchError((_) => <Object?>[]);
  }

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(allSubscriptionsProvider).value ?? [];
    // La scheda Abbonamenti c'è solo con almeno un pacchetto.
    final tabs = [
      _Tab.bookings,
      _Tab.matches,
      _Tab.lessons,
      if (subscriptions.isNotEmpty) _Tab.subscriptions,
    ];
    final tab = tabs.contains(_tab) ? _tab : _Tab.bookings;
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Profilo',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const Spacer(),
                    const ThemeToggleButton(),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: () =>
                          context.pushNamed(AppRoutes.notifications),
                      tooltip: 'Centro notifiche',
                      style: IconButton.styleFrom(
                        backgroundColor: context.colors.surface,
                        side: BorderSide(color: context.colors.border),
                        fixedSize: const Size.square(44),
                      ),
                      icon: Badge(
                        isLabelVisible: unread > 0,
                        label: Text(unread > 99 ? '99+' : '$unread'),
                        child: Icon(
                          Icons.notifications_none,
                          color: context.colors.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: () => context.goNamed(AppRoutes.settings),
                      tooltip: 'Impostazioni',
                      style: IconButton.styleFrom(
                        backgroundColor: context.colors.surface,
                        side: BorderSide(color: context.colors.border),
                        fixedSize: const Size.square(44),
                      ),
                      icon: Icon(
                        Icons.settings_outlined,
                        color: context.colors.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _ProfileCard(),
                const SizedBox(height: 14),
                const _PlayerPerformance(),
                const SizedBox(height: 20),
                _Tabs(
                  tabs: tabs,
                  selected: tab,
                  onSelected: (t) => setState(() => _tab = t),
                ),
                const SizedBox(height: 12),
                switch (tab) {
                  _Tab.bookings => const _BookingsTab(),
                  _Tab.matches => const _MatchesTab(),
                  _Tab.lessons => const _LessonsTab(),
                  _Tab.subscriptions => _SubscriptionsTab(subscriptions),
                },
                const SizedBox(height: 28),
                _AccountActions(
                  onLogout: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                  onDelete: () => confirmDeleteAccount(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final stats = ref.watch(profileStatsProvider);
    final colors = context.colors;
    final s = stats.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (s == null)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 32,
                      color: colors.primary,
                    ),
                  )
                else
                  PlayerMoodAvatar(stats: s, size: 64, showLabel: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? '',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                      if (s != null) ...[
                        const SizedBox(height: 4),
                        _BandBadge(name: s.bandName, color: s.bandColor),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.hasError)
              ErrorCard(
                message: 'Non riesco a caricare le statistiche',
                onRetry: () => ref.invalidate(profileStatsProvider),
              )
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.9,
                children: [
                  _Stat(
                    icon: Icons.bar_chart,
                    value: s?.position == null ? '—' : '${s!.position}°',
                    label: 'Posizione',
                    highlight: true,
                  ),
                  _Stat(
                    icon: Icons.sports_tennis,
                    value: '${s?.matchesPlayed ?? 0}',
                    label: 'Partite',
                  ),
                  _Stat(
                    icon: Icons.emoji_events_outlined,
                    value: '${s?.matchesWon ?? 0}',
                    label: 'Vittorie',
                    highlight: true,
                  ),
                  _Stat(
                    icon: Icons.trending_up,
                    value: '${s?.winRate ?? 0}%',
                    label: 'Win rate',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerPerformance extends ConsumerWidget {
  const _PlayerPerformance();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider).value;
    if (stats == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.colors.primaryTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insights_outlined,
                    color: context.colors.primaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prestazioni personali',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Forma, risultati e rendimento',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _trendColor(context, stats).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    stats.trendLabel,
                    style: TextStyle(
                      color: _trendColor(context, stats),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
              children: [
                _Gauge(
                  label: 'Vittorie',
                  value: stats.winRate,
                  caption: '${stats.matchesWon} vinte',
                  color: Colors.green,
                ),
                _Gauge(
                  label: 'Sconfitte',
                  value: stats.lossRate,
                  caption: '${stats.matchesLost} perse',
                  color: Colors.red,
                ),
                _Gauge(
                  label: 'Forma',
                  value: stats.recentFormRate,
                  caption: '${stats.recentWins}/${stats.recentMatches} recenti',
                  color: context.colors.primary,
                ),
                _Gauge(
                  label: 'Game vinti',
                  value: stats.gameWinRate,
                  caption:
                      '${stats.gamesWon}/${stats.gamesWon + stats.gamesLost}',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            _MetricGroup(
              title: 'Attività',
              icon: Icons.sports_tennis_outlined,
              color: Colors.orange,
              metrics: [
                ('Ranking', '${stats.rankingMatches}'),
                ('Amichevoli', '${stats.friendlyMatches}'),
                ('Tornei', '${stats.tournamentMatches}'),
                ('Senza esito', '${stats.undecided}'),
              ],
            ),
            const SizedBox(height: 14),
            _MetricGroup(
              title: 'Set e game',
              icon: Icons.scoreboard_outlined,
              color: Colors.blue,
              metrics: [
                ('Set vinti', '${stats.setsWon}'),
                ('Set persi', '${stats.setsLost}'),
                ('% set', '${stats.setWinRate}%'),
                ('Differenza game', '${stats.gamesWon - stats.gamesLost}'),
              ],
            ),
            const SizedBox(height: 14),
            _MetricGroup(
              title: 'Ranking',
              icon: Icons.workspace_premium_outlined,
              color: context.colors.primary,
              metrics: [
                (
                  'Da sfavorito',
                  'Partite: ${stats.underdogMatches}\n'
                      'Vittorie: ${stats.underdogWins}',
                ),
                (
                  'Da favorito',
                  'Partite: ${stats.favoriteMatches}\n'
                      'Vittorie: ${stats.favoriteWins}',
                ),
                (
                  'PR conquistati',
                  NumberFormat(
                    '0.0#',
                    'it_IT',
                  ).format(stats.rankingPointsEarned),
                ),
                (
                  'Media PR',
                  NumberFormat(
                    '0.0#',
                    'it_IT',
                  ).format(stats.rankingPointsAverage),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  final String label;
  final int value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      border: Border.all(color: color.withValues(alpha: 0.28)),
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value.clamp(0, 100) / 100,
                strokeWidth: 7,
                color: color,
                backgroundColor: color.withValues(alpha: 0.16),
              ),
              Text(
                '$value%',
                style: context.fonts.monoStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            height: 1.15,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _MetricGroup extends StatelessWidget {
  const _MetricGroup({
    required this.title,
    required this.icon,
    required this.color,
    required this.metrics,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<(String, String)> metrics;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 9),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      const SizedBox(height: 10),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metrics.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: metrics.any((metric) => metric.$2.contains('\n'))
              ? 1.35
              : 2.35,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              border: Border.all(color: color.withValues(alpha: 0.20)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                Text(
                  metric.$2,
                  style: context.fonts
                      .monoStyle(
                        fontSize: metric.$2.contains('\n') ? 14 : 17,
                        fontWeight: FontWeight.w700,
                      )
                      .copyWith(height: metric.$2.contains('\n') ? 1.35 : null),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}

Color _trendColor(BuildContext context, ProfileStats stats) =>
    stats.trendDelta < -5
    ? Colors.red
    : stats.trendDelta > 5
    ? Colors.green
    : context.colors.textSecondary;

class _AccountActions extends StatelessWidget {
  const _AccountActions({required this.onLogout, required this.onDelete});

  final VoidCallback onLogout;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Divider(color: context.colors.border),
      const SizedBox(height: 8),
      Text(
        'ACCOUNT',
        style: context.fonts
            .monoStyle(fontSize: 11, fontWeight: FontWeight.w700)
            .copyWith(color: context.colors.textSecondary),
      ),
      const SizedBox(height: 6),
      TextButton.icon(
        onPressed: onLogout,
        style: TextButton.styleFrom(
          foregroundColor: context.colors.textSecondary,
        ),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Esci'),
      ),
      TextButton.icon(
        onPressed: onDelete,
        style: TextButton.styleFrom(
          foregroundColor: context.colors.primaryText,
        ),
        icon: const Icon(Icons.delete_outline, size: 18),
        label: const Text('Elimina account'),
      ),
    ],
  );
}

class _BandBadge extends StatelessWidget {
  const _BandBadge({this.name, this.color});

  final String? name;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dot = parseHexColor(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            name == null ? 'Fuori fascia' : 'Fascia $name',
            style: context.fonts
                .monoStyle(fontSize: 11, fontWeight: FontWeight.w600)
                .copyWith(color: colors.primaryText),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = highlight ? colors.primaryText : colors.text;
    return Container(
      decoration: BoxDecoration(
        color: colors.divider,
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          Text(
            value,
            style: context.fonts
                .monoStyle(fontSize: 18, fontWeight: FontWeight.w600)
                .copyWith(color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<_Tab> tabs;
  final _Tab selected;
  final ValueChanged<_Tab> onSelected;

  static (IconData, String) _info(_Tab tab) => switch (tab) {
    _Tab.bookings => (Icons.calendar_today_outlined, 'Prenotazioni'),
    _Tab.matches => (Icons.sports_tennis, 'Partite'),
    _Tab.lessons => (Icons.school_outlined, 'Lezioni'),
    _Tab.subscriptions => (Icons.credit_card, 'Abbonamenti'),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.divider,
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tab in tabs)
              Semantics(
                selected: tab == selected,
                button: true,
                child: Material(
                  color: tab == selected ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  child: InkWell(
                    onTap: () => onSelected(tab),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            _info(tab).$1,
                            size: 16,
                            color: tab == selected
                                ? colors.text
                                : colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _info(tab).$2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: tab == selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: tab == selected
                                  ? colors.text
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Riga di uno storico: titolo, sottotitolo, stato e azione facoltativa.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.title,
    required this.subtitle,
    required this.status,
    this.positive = false,
    this.onCancel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final bool positive;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: positive ? colors.primaryTint : colors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: positive
                          ? colors.primaryText
                          : colors.textSecondary,
                    ),
                  ),
                ),
              if (onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primaryText,
                  ),
                  child: const Text('Cancella'),
                )
              else
                const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.colors.textSecondary),
      ),
    ),
  );
}

String _dayAndSlot(DateTime date, String slot) =>
    '${DateFormat('d MMM yyyy', Dates.locale).format(date)} • $slot';

class _BookingsTab extends ConsumerWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    return AsyncValueView(
      value: ref.watch(bookingHistoryProvider),
      errorText: 'Non riesco a caricare le prenotazioni',
      onRetry: () => ref.invalidate(bookingHistoryProvider),
      data: (list) => list.isEmpty
          ? const _Empty('Nessuna prenotazione')
          : Column(
              children: [
                for (final b in list) ...[
                  _HistoryRow(
                    title: b.courtName,
                    subtitle: _dayAndSlot(b.date, b.timeSlot),
                    status: bookingStatusLabel(b.status),
                    positive: b.status == BookingStatus.confirmed,
                    onCancel:
                        b.status == BookingStatus.confirmed &&
                            b.start.isAfter(now)
                        ? () async {
                            final done = await confirmAndCancelBooking(
                              context,
                              ref,
                              bookingId: b.id,
                              date: b.date,
                              description: bookingDescription(b),
                            );
                            if (done) ref.invalidate(bookingHistoryProvider);
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _MatchesTab extends ConsumerWidget {
  const _MatchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(matchHistoryProvider),
    errorText: 'Non riesco a caricare le partite',
    onRetry: () => ref.invalidate(matchHistoryProvider),
    data: (list) => list.isEmpty
        ? const _Empty('Nessuna partita')
        : Column(
            children: [
              for (final m in list) ...[
                _HistoryRow(
                  title:
                      'Partita del '
                      '${DateFormat('d MMM yyyy', Dates.locale).format(m.date)}',
                  subtitle:
                      '${m.slot?.label ?? m.timeSlot} • '
                      '${m.players.length} giocatori',
                  status: matchStatusShort(m.status),
                  onTap: () => context.pushNamed(
                    AppRoutes.matchDetail,
                    pathParameters: {'id': m.id},
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
  );
}

class _LessonsTab extends ConsumerWidget {
  const _LessonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    return AsyncValueView(
      value: ref.watch(lessonsProvider),
      errorText: 'Non riesco a caricare le lezioni',
      onRetry: () => ref.invalidate(lessonsProvider),
      data: (list) => list.isEmpty
          ? const _Empty('Nessuna lezione')
          : Column(
              children: [
                for (final l in list) ...[
                  _HistoryRow(
                    title: l.coachName.isEmpty
                        ? 'Lezione'
                        : 'Lezione con ${l.coachName}',
                    subtitle: _dayAndSlot(l.date, l.timeSlot),
                    status: lessonStatusLabel(l.status),
                    positive: l.status == LessonStatus.confirmed,
                    onCancel:
                        l.status == LessonStatus.confirmed &&
                            !l.date.isBefore(dateOnlyToday(now))
                        ? () => _cancelLesson(context, ref, l)
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }

  Future<void> _cancelLesson(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancellare la lezione?'),
        content: Text(
          '${lesson.coachName} · ${_dayAndSlot(lesson.date, lesson.timeSlot)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, tienila'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancella lezione'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(profileRepositoryProvider).cancelLesson(lesson.id);
      ref
        ..invalidate(lessonsProvider)
        ..invalidate(scheduleProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Lezione cancellata')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Cancellazione non riuscita')),
      );
    }
  }
}

DateTime dateOnlyToday(DateTime now) => DateTime(now.year, now.month, now.day);

class _SubscriptionsTab extends StatelessWidget {
  const _SubscriptionsTab(this.subscriptions);

  final List<PlayerSubscription> subscriptions;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final s in subscriptions) ...[
        SubscriptionCard(subscription: s),
        const SizedBox(height: 10),
      ],
    ],
  );
}

/// Card di un pacchetto come sul sito, con "Dettagli ›".
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key, required this.subscription});

  final PlayerSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    final colors = context.colors;
    Widget kv(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoutes.subscriptionDetail,
          pathParameters: {'id': s.id},
          extra: s,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.planName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontSize: 16),
                        ),
                        if (s.soldByClubName != null)
                          Text(
                            'Acquistato presso ${s.soldByClubName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      subscriptionStatusLabel(s.status),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: kv(
                      'Attivazione',
                      s.activatedAt == null
                          ? 'Al primo utilizzo'
                          : Dates.numeric(s.activatedAt!.toLocal()),
                    ),
                  ),
                  Expanded(
                    child: kv(
                      'Scadenza',
                      s.expiresAt == null
                          ? '—'
                          : Dates.numeric(s.expiresAt!.toLocal()),
                    ),
                  ),
                ],
              ),
              if (s.matchesTotal != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: kv('Disponibili', '${s.matchesAvailable ?? 0}'),
                    ),
                    Expanded(child: kv('Utilizzate', '${s.matchesUsed}')),
                  ],
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Dettagli ›',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
