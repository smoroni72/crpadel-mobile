import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_controller.dart';

class AuthenticatedShell extends ConsumerStatefulWidget {
  const AuthenticatedShell({super.key});

  @override
  ConsumerState<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends ConsumerState<AuthenticatedShell> {
  int _index = 0;

  static const _pages = [
    _HomePage(),
    _ModulePage(
      title: 'Prenota',
      subtitle: 'Scegli giorno, durata, orario e campo disponibile.',
      icon: Icons.calendar_month_outlined,
    ),
    _ModulePage(
      title: 'Partite',
      subtitle: 'Apri una partita, partecipa e inserisci il risultato.',
      icon: Icons.sports_tennis_outlined,
    ),
    _ModulePage(
      title: 'Circolo',
      subtitle: 'News, eventi, tornei, galleria e informazioni del circolo.',
      icon: Icons.apartment_outlined,
    ),
    _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _index, children: _pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Prenota',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_tennis_outlined),
          selectedIcon: Icon(Icons.sports_tennis),
          label: 'Partite',
        ),
        NavigationDestination(
          icon: Icon(Icons.apartment_outlined),
          selectedIcon: Icon(Icons.apartment),
          label: 'Circolo',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profilo',
        ),
      ],
    ),
  );
}

class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CRPadel',
          style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.w800),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text('Pronto per la prossima partita?'),
          const SizedBox(height: 22),
          const _StatusCard(),
          const SizedBox(height: 22),
          const _SectionTitle('Le tue prossime prenotazioni'),
          const _EmptyCard(
            icon: Icons.calendar_today_outlined,
            text: 'Nessuna prenotazione futura',
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Le tue prossime partite'),
          const _EmptyCard(
            icon: Icons.sports_tennis_outlined,
            text: 'Nessuna partita futura',
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Partite aperte'),
          const _EmptyCard(
            icon: Icons.group_add_outlined,
            text: 'Le partite a cui puoi unirti appariranno qui',
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) => Card(
    color: AppTheme.navy,
    child: const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Abbonamento e pacchetti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'La situazione aggiornata sarà mostrata qui.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    ),
  );
}

class _ProfilePage extends ConsumerWidget {
  const _ProfilePage();

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
          const _EmptyCard(
            icon: Icons.leaderboard_outlined,
            text: 'Ranking, fascia e statistiche sportive',
          ),
          const SizedBox(height: 12),
          const _EmptyCard(
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

class _ModulePage extends StatelessWidget {
  const _ModulePage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: AppTheme.red),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Text(
              'Modulo predisposto per il collegamento alle API.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.red),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}
