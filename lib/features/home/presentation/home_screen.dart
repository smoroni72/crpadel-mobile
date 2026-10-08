import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bookings/presentation/upcoming_bookings_provider.dart';
import '../../bookings/presentation/widgets/booking_card.dart';
import '../../matches/presentation/day_matches_provider.dart';
import '../../matches/presentation/widgets/day_strip.dart';
import '../../matches/presentation/widgets/match_card.dart';
import '../../subscriptions/presentation/subscription_summary_card.dart';
import '../../subscriptions/presentation/subscriptions_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    final day = ref.read(selectedDayProvider);
    await Future.wait<Object?>([
      ref.refresh(usableSubscriptionsProvider.future),
      ref.refresh(upcomingBookingsProvider.future),
      ref.refresh(dayMatchesProvider(day).future),
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final today = ref.watch(clockProvider)();
    final colors = context.colors;
    final firstName = user?.fullName.trim().split(' ').first ?? '';
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
        IconButton.outlined(
          onPressed: () {},
          tooltip: 'Notifiche',
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            side: BorderSide(color: colors.border),
            fixedSize: const Size.square(44),
          ),
          icon: Icon(Icons.notifications_none, color: colors.text),
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
    final userId = ref.watch(authControllerProvider).value?.id ?? '';
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
                      MatchCard(match: match, myUserId: userId),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
