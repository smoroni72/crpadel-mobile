import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppTheme.navy,
            child: Text(
              user?.fullName.substring(0, 1).toUpperCase() ?? 'G',
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.fullName ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(user?.email ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const EmptyStateCard(
            icon: Icons.leaderboard_outlined,
            text: 'Ranking, fascia e statistiche sportive',
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            icon: Icons.card_membership_outlined,
            text: 'Abbonamenti e crediti disponibili',
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Esci'),
          ),
        ],
      ),
    );
  }
}
