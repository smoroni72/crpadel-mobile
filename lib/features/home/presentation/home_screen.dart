import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../subscriptions/presentation/subscription_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CRPadel',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifiche',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Ciao, ${user?.fullName.split(' ').first ?? 'giocatore'}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Pronto per la prossima partita?'),
          const SizedBox(height: 22),
          const SubscriptionSummaryCard(),
          const SizedBox(height: 22),
          const SectionTitle('Le tue prenotazioni'),
          const EmptyStateCard(
            icon: Icons.calendar_today_outlined,
            text: 'Nessuna prenotazione futura',
          ),
          const SizedBox(height: 22),
          const SectionTitle('Partite del giorno'),
          const EmptyStateCard(
            icon: Icons.sports_tennis_outlined,
            text: 'Le partite del circolo appariranno qui',
          ),
        ],
      ),
    );
  }
}
