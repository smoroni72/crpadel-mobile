import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/padel_match.dart';
import '../../matches/presentation/widgets/connected_match_card.dart';
import '../data/admin_repository.dart';
import 'admin_providers.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value!;
    final overview = ref.watch(adminOverviewProvider);
    final entries = <_AdminEntry>[
      if (user.canAccessAdminMenu('matches'))
        const _AdminEntry(
          'Partite e risultati',
          'Completa, controlla e correggi le partite',
          Icons.sports_tennis,
          AppRoutes.adminMatches,
        ),
      if (user.canAccessAdminMenu('bookings'))
        const _AdminEntry(
          'Prenotazioni',
          'Controlla l’agenda e le prenotazioni',
          Icons.calendar_month_outlined,
          AppRoutes.adminBookings,
        ),
      if (user.canAccessAdminMenu('players'))
        const _AdminEntry(
          'Giocatori',
          'Cerca anagrafiche e dati ranking',
          Icons.groups_outlined,
          AppRoutes.adminPlayers,
        ),
      if (user.canAccessAdminMenu('rankings'))
        const _AdminEntry(
          'Classifiche',
          'Generale, mensile e decadi precedenti',
          Icons.leaderboard_outlined,
          AppRoutes.rankings,
        ),
      if (user.canAccessAdminMenu('push_notifications'))
        const _AdminEntry(
          'Comunicazioni',
          'Invia notifiche e controlla lo storico',
          Icons.campaign_outlined,
          AppRoutes.adminCommunications,
        ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Amministrazione')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminOverviewProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Card(
              color: context.colors.navy,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 36,
                      color: context.colors.onNavy,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: context.colors.onNavy),
                          ),
                          Text(
                            user.isSuperAdmin ? 'Super Admin' : 'Admin',
                            style: TextStyle(
                              color: context.colors.onNavy.withValues(
                                alpha: .75,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AsyncValueView(
              value: overview,
              errorText: 'Non riesco a caricare il riepilogo',
              onRetry: () => ref.invalidate(adminOverviewProvider),
              data: (data) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _Metric('Partite', '${data.matches}', Icons.sports_tennis),
                  _Metric(
                    'Risultati attesi',
                    '${data.pendingResults}',
                    Icons.flag_outlined,
                  ),
                  _Metric(
                    'Prenotazioni',
                    '${data.bookings}',
                    Icons.calendar_month_outlined,
                  ),
                  _Metric(
                    'Giocatori',
                    '${data.players}',
                    Icons.groups_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Gestione', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Non hai ancora permessi amministrativi attivi.'),
                ),
              ),
            for (final entry in entries)
              Card(
                child: ListTile(
                  leading: Icon(entry.icon, color: context.colors.primary),
                  title: Text(entry.title),
                  subtitle: Text(entry.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(entry.route),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.colors.primary),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(label, style: TextStyle(color: context.colors.textSecondary)),
        ],
      ),
    ),
  );
}

class _AdminEntry {
  const _AdminEntry(this.title, this.subtitle, this.icon, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

final _adminMatchesProvider = FutureProvider<List<PadelMatch>>((ref) {
  final now = DateTime.now();
  return ref
      .read(matchesRepositoryProvider)
      .between(
        now.subtract(const Duration(days: 60)),
        now.add(const Duration(days: 60)),
      );
});

class AdminMatchesScreen extends ConsumerWidget {
  const AdminMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(_adminMatchesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Partite e risultati')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_adminMatchesProvider.future),
        child: AsyncValueView(
          value: matches,
          errorText: 'Non riesco a caricare le partite',
          onRetry: () => ref.invalidate(_adminMatchesProvider),
          data: (items) {
            final sorted = [...items]
              ..sort((a, b) {
                final aPending =
                    a.status == MatchStatus.pendingResult ||
                    a.status == MatchStatus.inProgress;
                final bPending =
                    b.status == MatchStatus.pendingResult ||
                    b.status == MatchStatus.inProgress;
                if (aPending != bPending) return aPending ? -1 : 1;
                return b.start.compareTo(a.start);
              });
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  'I risultati da inserire sono mostrati per primi.',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 12),
                for (final match in sorted) ...[
                  ConnectedMatchCard(match: match, adminMode: true),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(adminBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Prenotazioni')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminBookingsProvider.future),
        child: AsyncValueView(
          value: bookings,
          errorText: 'Non riesco a caricare le prenotazioni',
          onRetry: () => ref.invalidate(adminBookingsProvider),
          data: (items) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.calendar_month_outlined,
                    color: context.colors.primary,
                  ),
                  title: Text(item.playerName),
                  subtitle: Text(
                    '${item.date} · ${item.time}\n${item.courtName} · ${item.type}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    item.status,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AdminPlayersScreen extends ConsumerStatefulWidget {
  const AdminPlayersScreen({super.key});

  @override
  ConsumerState<AdminPlayersScreen> createState() => _AdminPlayersScreenState();
}

class _AdminPlayersScreenState extends ConsumerState<AdminPlayersScreen> {
  final controller = TextEditingController();
  var search = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(adminPlayersProvider(search));
    return Scaffold(
      appBar: AppBar(title: const Text('Giocatori')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => setState(() => search = value),
              decoration: InputDecoration(
                labelText: 'Cerca nome, email o telefono',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => search = controller.text),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: players,
              errorText: 'Non riesco a caricare i giocatori',
              onRetry: () => ref.invalidate(adminPlayersProvider(search)),
              data: (items) => RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(adminPlayersProvider(search).future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(item.name.isEmpty ? '?' : item.name[0]),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.email}\n${item.matches} PG · ${item.wins} V · ${item.points.toStringAsFixed(2)} PR',
                        ),
                        isThreeLine: true,
                        trailing: Text(item.status),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminCommunicationsScreen extends ConsumerWidget {
  const AdminCommunicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communications = ref.watch(adminCommunicationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Comunicazioni')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _compose(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nuova'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminCommunicationsProvider.future),
        child: AsyncValueView(
          value: communications,
          errorText: 'Non riesco a caricare le comunicazioni',
          onRetry: () => ref.invalidate(adminCommunicationsProvider),
          data: (items) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.campaign_outlined,
                    color: context.colors.primary,
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    '${item.body}\n${item.createdAt == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt!.toLocal())}',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '${item.recipientCount}\n${item.status}',
                    textAlign: TextAlign.end,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _compose(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final body = TextEditingController();
    String? destination;
    final send = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuova comunicazione'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Titolo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: body,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Messaggio'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: destination,
                  decoration: const InputDecoration(
                    labelText: 'Apertura nell’app',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Nessuna destinazione'),
                    ),
                    DropdownMenuItem(value: 'partite', child: Text('Partite')),
                    DropdownMenuItem(
                      value: 'prenotazioni',
                      child: Text('Prenotazioni'),
                    ),
                    DropdownMenuItem(value: 'tornei', child: Text('Tornei')),
                    DropdownMenuItem(value: 'news', child: Text('News')),
                  ],
                  onChanged: (value) => setState(() => destination = value),
                ),
                const SizedBox(height: 10),
                const Text(
                  'La comunicazione sarà inviata a tutti gli utenti del circolo.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty || body.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Continua'),
            ),
          ],
        ),
      ),
    );
    if (send != true || !context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inviare a tutti?'),
        content: Text(
          'Stai per inviare “${title.text.trim()}” a tutti gli utenti del circolo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Indietro'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Invia'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final count = await ref
          .read(adminRepositoryProvider)
          .sendCommunication(
            title: title.text,
            body: body.text,
            destination: destination,
          );
      ref.invalidate(adminCommunicationsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comunicazione preparata per $count destinatari'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
    title.dispose();
    body.dispose();
  }
}
