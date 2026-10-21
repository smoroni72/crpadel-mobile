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
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                    onPressed: () => context.pushNamed(AppRoutes.notifications),
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
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Esci'),
                ),
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () => confirmDeleteAccount(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.primaryText,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Elimina account'),
                ),
              ),
            ],
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
                ),
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
