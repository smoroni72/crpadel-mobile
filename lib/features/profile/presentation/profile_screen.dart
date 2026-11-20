import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../admin/presentation/admin_menu_button.dart';
import '../../bookings/domain/booking.dart';
import '../../bookings/presentation/book_providers.dart';
import '../../bookings/presentation/cancel_booking.dart';
import '../../subscriptions/domain/player_subscription.dart';
import '../../notifications/presentation/notifications_provider.dart';
import '../../app_menu/domain/app_menu_configuration.dart';
import '../../app_menu/presentation/app_menu_provider.dart';
import '../data/profile_repository.dart';
import '../domain/profile_models.dart';
import 'delete_account.dart';
import 'profile_labels.dart';
import 'profile_providers.dart';
import 'widgets/player_mood_avatar.dart';
import 'widgets/player_pairings_table.dart';
import 'widgets/player_expected_performance.dart';
import 'widgets/player_card_button.dart';
import 'widgets/player_avatar.dart';

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
    final menuConfiguration =
        ref.watch(appMenuConfigurationProvider).value ??
        AppMenuConfiguration.allEnabled;
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
                    const AdminMenuButton(),
                    const SizedBox(width: 8),
                    if (menuConfiguration.notifications) ...[
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
                    ],
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
                const _RankingRulesCard(),
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
    final bandColor = parseHexColor(s?.bandColor) ?? colors.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = bandColor.computeLuminance() > .72
        ? (dark ? Colors.white : colors.navy)
        : bandColor;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: dark ? .55 : .38),
          width: dark ? 1 : 1.25,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
                  bandColor.withValues(alpha: .27),
                  colors.surface,
                  colors.surface,
                ]
              : [
                  Color.alphaBlend(
                    accentColor.withValues(alpha: .13),
                    colors.surface,
                  ),
                  const Color(0xFFF5F8FC),
                  colors.surface,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (dark ? bandColor : colors.navy).withValues(
              alpha: dark ? .12 : .10,
            ),
            blurRadius: dark ? 24 : 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
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
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor, width: 3),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        PlayerAvatar(
                          name: user?.fullName ?? '',
                          photoUrl: s.photoUrl,
                          size: 70,
                        ),
                        Positioned(
                          right: -5,
                          bottom: -5,
                          child: PlayerMoodAvatar(stats: s, size: 28),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
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
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _choosePlayerPhoto(context, ref, s),
                              icon: const Icon(
                                Icons.add_a_photo_outlined,
                                size: 17,
                              ),
                              label: const Text('Foto profilo'),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: s.photoPublicConsent,
                                  onChanged: s.photoUrl == null
                                      ? null
                                      : (value) async {
                                          await ref
                                              .read(profileRepositoryProvider)
                                              .updatePhoto(
                                                publicConsent: value == true,
                                              );
                                          ref.invalidate(profileStatsProvider);
                                        },
                                ),
                                const Flexible(
                                  child: Text(
                                    'Visibile in classifiche e podi',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
              Column(
                children: [
                  Row(
                    children: [
                      _ProfileHeroMetric(
                        label: 'POSIZIONE',
                        value: s?.position == null ? '—' : '${s!.position}°',
                      ),
                      _ProfileHeroDivider(color: bandColor),
                      _ProfileHeroMetric(
                        label: 'PUNTI',
                        value: s == null
                            ? '—'
                            : s.currentRankingScore.toStringAsFixed(2),
                      ),
                      _ProfileHeroDivider(color: bandColor),
                      _ProfileHeroMetric(
                        label: 'WIN RATE',
                        value: '${s?.winRate ?? 0}%',
                      ),
                    ],
                  ),
                  if (s != null && s.recentHistory.isNotEmpty) ...[
                    const SizedBox(height: 17),
                    Row(
                      children: [
                        Text(
                          'FORMA RECENTE · ULTIME ${s.recentHistory.length}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        for (final match in s.recentHistory) ...[
                          _ProfileFormDot(won: match.won),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'STORICO DISPONIBILE · ${s?.matchesPlayed ?? 0} TOTALI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${s?.matchesWon ?? 0} vittorie · ${s?.matchesLost ?? 0} sconfitte',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeroMetric extends StatelessWidget {
  const _ProfileHeroMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: context.fonts.monoStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _ProfileHeroDivider extends StatelessWidget {
  const _ProfileHeroDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: color.withValues(alpha: .35));
}

class _ProfileFormDot extends StatelessWidget {
  const _ProfileFormDot({required this.won});
  final bool won;

  @override
  Widget build(BuildContext context) {
    final color = won ? const Color(0xff16a34a) : const Color(0xffef4444);
    return Container(
      width: 27,
      height: 27,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .15),
        border: Border.all(color: color.withValues(alpha: .7)),
      ),
      child: Text(
        won ? 'V' : 'S',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

Future<void> _choosePlayerPhoto(
  BuildContext context,
  WidgetRef ref,
  ProfileStats stats,
) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Scatta un selfie'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Scegli dalla galleria'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return;
  try {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null || !context.mounted) return;

    // Su iOS il picker può restituire il file mentre la fotocamera è ancora in
    // chiusura. Presentare subito il cropper viene ignorato silenziosamente dal
    // sistema; attendiamo la fine della transizione prima di aprirlo.
    if (Platform.isIOS && source == ImageSource.camera) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!context.mounted) return;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      maxWidth: 640,
      maxHeight: 640,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 82,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ritaglia la foto',
          toolbarColor: const Color(0xFFEF382C),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFFEF382C),
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Ritaglia la foto',
          doneButtonTitle: 'Usa foto',
          cancelButtonTitle: 'Annulla',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped == null || !context.mounted) return;
    final jpeg = await cropped.readAsBytes();
    await ref
        .read(profileRepositoryProvider)
        .updatePhoto(jpeg: jpeg, publicConsent: stats.photoPublicConsent);
    ref.invalidate(profileStatsProvider);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Non è stato possibile salvare la foto. Riprova oppure scegli '
          'un’immagine dalla galleria.',
        ),
      ),
    );
  }
}

class _RankingRulesCard extends ConsumerWidget {
  const _RankingRulesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider).value;
    if (stats == null) return const SizedBox.shrink();
    final alerts = stats.rankingAlerts;
    final deadline = DateTime.tryParse(alerts.periodEnd);
    final deadlineLabel = deadline == null
        ? alerts.periodEnd
        : intl.DateFormat('d MMMM', 'it_IT').format(deadline);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: dark ? 0 : 3,
      shadowColor: context.colors.navy.withValues(alpha: .16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: dark
              ? context.colors.border
              : context.colors.navy.withValues(alpha: .20),
          width: dark ? 1 : 1.15,
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
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
                    color: alerts.hasRisk
                        ? Colors.orange.withValues(alpha: .14)
                        : Colors.green.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    alerts.hasRisk
                        ? Icons.notification_important_outlined
                        : Icons.verified_user_outlined,
                    color: alerts.hasRisk ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Situazione ranking',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        alerts.hasRisk
                            ? 'Attenzione: una regola può incidere sui punti'
                            : 'Nessuna penalizzazione attiva',
                        style: TextStyle(
                          fontSize: 12,
                          color: alerts.hasRisk
                              ? Colors.orange
                              : context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _RankingRuleTile(
              icon: Icons.trending_up,
              title: 'Partite consecutive da favorito',
              value: alerts.favoriteRuleEnabled
                  ? '${alerts.favoriteStreak} / ${alerts.favoriteThreshold}'
                  : 'Non attiva',
              warning: alerts.favoriteRisk,
              description: alerts.favoriteRisk
                  ? 'Soglia raggiunta: una nuova partita ancora da favorito assegna al massimo ${intl.NumberFormat('0.00', 'it_IT').format(alerts.favoritePointsAfterThreshold)} punti classifica; se il calcolo restituisce meno, resta valido il valore inferiore.'
                  : alerts.favoriteRuleEnabled
                  ? 'Il contatore torna a zero giocando a coefficiente pari o inferiore agli avversari.'
                  : 'Questa regola non è attiva nel periodo corrente.',
            ),
            const SizedBox(height: 10),
            _RankingRuleTile(
              icon: alerts.injuryExempt
                  ? Icons.health_and_safety_outlined
                  : Icons.event_busy_outlined,
              title: 'Presenza nella decade',
              value: alerts.injuryExempt
                  ? 'Congelato'
                  : '${alerts.matchesPlayedInDecade} / ${alerts.inactivityMinimumMatches}',
              warning: alerts.inactivityRisk,
              description: alerts.injuryExempt
                  ? 'Esenzione per infortunio attiva: nessuna penalizzazione per assenza.'
                  : alerts.inactivityRisk
                  ? 'Entro il $deadlineLabel serve una partita ranking: altrimenti ${intl.NumberFormat('0.##', 'it_IT').format(alerts.inactivityPenaltyPoints)} punto in classifica.${alerts.matchesScheduledInDecade > 0 ? ' Hai ${alerts.matchesScheduledInDecade} partita/e già in calendario.' : ''}'
                  : alerts.inactivityRuleEnabled
                  ? 'Requisito della decade raggiunto. Nessuna penalizzazione per assenza.'
                  : 'Questa regola non è attiva nel periodo corrente.',
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingRuleTile extends StatelessWidget {
  const _RankingRuleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.warning,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool warning;
  final String description;

  @override
  Widget build(BuildContext context) {
    final color = warning ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        border: Border.all(color: color.withValues(alpha: .30)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      value,
                      style: context.fonts
                          .monoStyle(fontWeight: FontWeight.w700)
                          .copyWith(color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final showRankingDetails =
        ref.watch(authControllerProvider).value?.isAdmin ?? false;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: dark ? 0 : 3,
      shadowColor: context.colors.navy.withValues(alpha: .16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: dark
              ? context.colors.border
              : context.colors.navy.withValues(alpha: .20),
          width: dark ? 1 : 1.15,
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
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
                        'Dati sulle ${stats.matchesPlayed} partite registrate',
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
            if (stats.recentHistory.isNotEmpty) ...[
              _PersonalTrendChart(matches: stats.recentHistory),
              const SizedBox(height: 18),
            ],
            PlayerPairingsTable(stats: stats),
            const SizedBox(height: 18),
            if (_hasPersonalHighlights(stats)) ...[
              _PersonalHighlights(stats: stats),
              const SizedBox(height: 18),
            ],
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
                ('Tie-break giocati', '${stats.tiebreaksPlayed}'),
                ('Tie-break vinti', '${stats.tiebreaksWon}'),
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
                  'A parità',
                  'Partite: ${stats.equalMatches}\nVittorie: ${stats.equalWins}',
                ),
                (
                  'Non terminate',
                  '${stats.unfinishedRankingMatches} · senza esito',
                ),
                if (stats.rankingMatchesWithoutCoefficients > 0)
                  (
                    'Senza coefficienti',
                    '${stats.rankingMatchesWithoutCoefficients} · fuori dal confronto',
                  ),
              ],
            ),
            const SizedBox(height: 14),
            PlayerExpectedPerformance(value: stats.performanceExpectation),
            const SizedBox(height: 14),
            const PlayerCardButton(),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.history_rounded, color: context.colors.primaryText),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    stats.recentHistory.isEmpty
                        ? 'Partite recenti'
                        : 'Ultime ${stats.recentHistory.length} partite',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              showRankingDetails
                  ? 'Avversari, risultato e punti classifica'
                  : 'Avversari e risultato',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            if (stats.recentHistory.isEmpty)
              Text(
                'Nessuna partita disponibile',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textSecondary),
              )
            else
              for (
                var index = 0;
                index < stats.recentHistory.length;
                index++
              ) ...[
                _PersonalRecentMatch(
                  match: stats.recentHistory[index],
                  showRankingDetails: showRankingDetails,
                ),
                if (index < stats.recentHistory.length - 1)
                  const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

String _signedProfileScore(double value) =>
    '${value > 0 ? '+' : ''}${value.toStringAsFixed(2).replaceAll('.', ',')}';

bool _hasPersonalHighlights(ProfileStats stats) =>
    stats.currentStreakCount > 0 || stats.badges.isNotEmpty;

class _PersonalHighlights extends StatelessWidget {
  const _PersonalHighlights({required this.stats});
  final ProfileStats stats;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: context.colors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: context.colors.primaryText),
            const SizedBox(width: 8),
            const Text(
              'Identità sportiva',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        if (stats.badges.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final badge in stats.badges)
                Chip(
                  avatar: const Icon(
                    Icons.workspace_premium_outlined,
                    size: 16,
                    color: Color(0xffd97706),
                  ),
                  label: Text(badge),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
        if (stats.currentStreakCount > 0) ...[
          const SizedBox(height: 10),
          _PersonalHighlightTile(
            icon: Icons.local_fire_department_rounded,
            title: 'Serie attuale',
            value: stats.currentStreakLabel,
          ),
        ],
      ],
    ),
  );
}

class _PersonalHighlightTile extends StatelessWidget {
  const _PersonalHighlightTile({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 19, color: context.colors.primaryText),
      const SizedBox(width: 9),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    ],
  );
}

class _PersonalTrendChart extends StatelessWidget {
  const _PersonalTrendChart({required this.matches});
  final List<RecentPlayerMatch> matches;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Andamento ultime ${matches.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Text(
          'Progressivo di vittorie e sconfitte',
          style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          width: double.infinity,
          child: CustomPaint(
            painter: _PersonalTrendPainter(
              matches: matches.reversed.toList(),
              gridColor: context.colors.divider,
              textColor: context.colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProfileLegend(color: Color(0xff16a34a), label: 'Vittorie'),
            SizedBox(width: 18),
            _ProfileLegend(color: Color(0xffef4444), label: 'Sconfitte'),
          ],
        ),
      ],
    ),
  );
}

class _ProfileLegend extends StatelessWidget {
  const _ProfileLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}

class _PersonalTrendPainter extends CustomPainter {
  _PersonalTrendPainter({
    required this.matches,
    required this.gridColor,
    required this.textColor,
  });

  final List<RecentPlayerMatch> matches;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(25, 10, size.width - 8, size.height - 27);
    final maxValue = math.max(matches.length, 1).toDouble();
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var row = 0; row <= matches.length; row++) {
      final y = chart.bottom - chart.height * row / maxValue;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }
    final wins = <Offset>[];
    final losses = <Offset>[];
    var win = 0;
    var loss = 0;
    for (var index = 0; index < matches.length; index++) {
      matches[index].won ? win++ : loss++;
      final x = matches.length == 1
          ? chart.center.dx
          : chart.left + chart.width * index / (matches.length - 1);
      wins.add(Offset(x, chart.bottom - chart.height * win / maxValue));
      losses.add(Offset(x, chart.bottom - chart.height * loss / maxValue));
      final date = DateTime.tryParse(matches[index].date);
      final label = date == null
          ? matches[index].date
          : intl.DateFormat('dd/MM').format(date);
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 9, color: textColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x - text.width / 2, chart.bottom + 7));
    }
    _drawLine(canvas, wins, const Color(0xff16a34a));
    _drawLine(canvas, losses, const Color(0xffef4444));
  }

  void _drawLine(Canvas canvas, List<Offset> points, Color color) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = color);
      canvas.drawCircle(point, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _PersonalTrendPainter oldDelegate) =>
      oldDelegate.matches != matches ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.textColor != textColor;
}

class _PersonalRecentMatch extends StatelessWidget {
  const _PersonalRecentMatch({
    required this.match,
    required this.showRankingDetails,
  });
  final RecentPlayerMatch match;
  final bool showRankingDetails;

  @override
  Widget build(BuildContext context) {
    final color = match.won ? const Color(0xff16a34a) : const Color(0xffef4444);
    final date = DateTime.tryParse(match.date);
    final dateLabel = date == null
        ? match.date
        : intl.DateFormat('dd MMM', 'it_IT').format(date);
    final opponents = match.opponents.isEmpty
        ? 'Avversari non indicati'
        : match.opponents.join(' / ');
    final mate = match.teamMates.isEmpty ? null : match.teamMates.join(' / ');
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: .14),
                ),
                child: Text(
                  match.won ? 'V' : 'S',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dateLabel${match.timeSlot.isEmpty ? '' : ' · ${match.timeSlot}'}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      match.courtName.isEmpty
                          ? 'Campo non indicato'
                          : match.courtName,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                match.score.isEmpty ? '—' : match.score,
                style: context.fonts.monoStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if (mate != null) _ProfileMatchLine(label: 'In coppia con $mate'),
          _ProfileMatchLine(label: 'vs $opponents'),
          if (showRankingDetails && match.rankingScoreDelta != null) ...[
            const SizedBox(height: 7),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_signedProfileScore(match.rankingScoreDelta!)} punti classifica',
                style: TextStyle(
                  fontSize: 11,
                  color: match.rankingScoreDelta! >= 0
                      ? const Color(0xff16a34a)
                      : const Color(0xffef4444),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMatchLine extends StatelessWidget {
  const _ProfileMatchLine({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Row(
      children: [
        Icon(
          Icons.sports_tennis_rounded,
          size: 13,
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
          ),
        ),
      ],
    ),
  );
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: dark ? colors.primaryTint : const Color(0xFFF2F5F9),
        border: Border.all(color: dark ? Colors.transparent : colors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
                border: dot.computeLuminance() > .72
                    ? Border.all(color: colors.textSecondary, width: .8)
                    : null,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            name == null ? 'Fuori fascia' : 'Fascia $name',
            style: context.fonts
                .monoStyle(fontSize: 11, fontWeight: FontWeight.w600)
                .copyWith(color: dark ? colors.primaryText : colors.navy),
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
    '${intl.DateFormat('d MMM yyyy', Dates.locale).format(date)} • $slot';

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
                      '${intl.DateFormat('d MMM yyyy', Dates.locale).format(m.date)}',
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
