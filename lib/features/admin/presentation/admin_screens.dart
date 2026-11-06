import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../matches/domain/padel_match.dart';
import '../../matches/presentation/day_matches_provider.dart';
import '../../matches/presentation/match_providers.dart';
import '../../matches/presentation/widgets/connected_match_card.dart';
import '../../matches/presentation/widgets/day_strip.dart';
import '../data/admin_repository.dart';
import 'admin_providers.dart';
import 'admin_menu_button.dart';

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
      if (user.canAccessAdminMenu('matches'))
        const _AdminEntry(
          'Storico partite',
          'Filtra per periodo e giocatore',
          Icons.history,
          AppRoutes.adminMatchHistory,
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
      if (user.canAccessAdminMenu('users'))
        const _AdminEntry(
          'Utenti',
          'Crea e controlla gli account di accesso',
          Icons.manage_accounts_outlined,
          AppRoutes.adminUsers,
        ),
      if (user.canAccessAdminMenu('statistics'))
        const _AdminEntry(
          'Statistiche',
          'Andamento del circolo nel periodo',
          Icons.query_stats,
          AppRoutes.adminStatistics,
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
      appBar: AppBar(
        title: const Text('Amministrazione'),
        actions: const [AdminMenuButton()],
      ),
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

class AdminMatchesScreen extends ConsumerStatefulWidget {
  const AdminMatchesScreen({super.key});

  @override
  ConsumerState<AdminMatchesScreen> createState() => _AdminMatchesScreenState();
}

class _AdminMatchesScreenState extends ConsumerState<AdminMatchesScreen> {
  late DateTime day;
  var onlyPendingResults = false;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    day = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(dayMatchesProvider(day));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario partite'),
        actions: [
          IconButton(
            tooltip: 'Storico partite',
            onPressed: () => context.pushNamed(AppRoutes.adminMatchHistory),
            icon: const Icon(Icons.history),
          ),
          const AdminMenuButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.adminCreateMatch),
        icon: const Icon(Icons.add),
        label: const Text('Nuova partita'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.refresh(dayMatchesProvider(day).future),
            ref.refresh(matchDatesProvider(day).future),
          ]);
        },
        child: AsyncValueView(
          value: matches,
          errorText: 'Non riesco a caricare le partite',
          onRetry: () => ref.invalidate(dayMatchesProvider(day)),
          data: (items) {
            final pendingResults = items
                .where((match) => match.status == MatchStatus.pendingResult)
                .toList();
            final visibleItems = onlyPendingResults ? pendingResults : items;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                DayStrip(
                  selected: day,
                  matchDates:
                      ref.watch(matchDatesProvider(day)).value ?? const {},
                  onSelected: (value) => setState(() => day = value),
                  onPrevious: () => setState(
                    () => day = day.subtract(const Duration(days: 5)),
                  ),
                  onNext: () =>
                      setState(() => day = day.add(const Duration(days: 5))),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    avatar: const Icon(
                      Icons.pending_actions_outlined,
                      size: 18,
                    ),
                    label: Text(
                      'Risultato da inserire (${pendingResults.length})',
                    ),
                    selected: onlyPendingResults,
                    onSelected: (value) =>
                        setState(() => onlyPendingResults = value),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${Dates.longDay(day)} · ${visibleItems.length} '
                  '${visibleItems.length == 1 ? 'partita' : 'partite'}',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 12),
                if (visibleItems.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Text(
                        onlyPendingResults
                            ? 'Nessuna partita richiede l’inserimento del risultato in questa giornata.'
                            : 'Nessuna partita in questa giornata.',
                      ),
                    ),
                  )
                else
                  for (final match in visibleItems) ...[
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
      appBar: AppBar(
        title: const Text('Prenotazioni campi'),
        actions: const [AdminMenuButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(AppRoutes.book),
        icon: const Icon(Icons.add),
        label: const Text('Nuova prenotazione'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminBookingsProvider.future),
        child: AsyncValueView(
          value: bookings,
          errorText: 'Non riesco a caricare le prenotazioni',
          onRetry: () => ref.invalidate(adminBookingsProvider),
          data: (items) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
      appBar: AppBar(
        title: const Text('Giocatori'),
        actions: const [AdminMenuButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createPlayer(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuovo giocatore'),
      ),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
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

  Future<void> _createPlayer(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    DateTime? birthDate;
    var gender = 'male';
    String? preferredSide;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuovo giocatore'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome e cognome *',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefono'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data di nascita *'),
                  subtitle: Text(
                    birthDate == null ? 'Seleziona' : Dates.numeric(birthDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1985),
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                      locale: const Locale('it', 'IT'),
                    );
                    if (selected != null) {
                      setDialogState(() => birthDate = selected);
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: const InputDecoration(labelText: 'Sesso *'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Maschile')),
                    DropdownMenuItem(value: 'female', child: Text('Femminile')),
                    DropdownMenuItem(value: 'other', child: Text('Altro')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => gender = value ?? 'male'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  initialValue: preferredSide,
                  decoration: const InputDecoration(
                    labelText: 'Lato preferito',
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Non indicato'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'SX',
                      child: Text('Sinistra'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'DX',
                      child: Text('Destra'),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => preferredSide = value),
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
                if (name.text.trim().isEmpty || birthDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inserisci nome e data di nascita'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Crea'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted || birthDate == null) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .createPlayer(
            fullName: name.text,
            birthDate: Dates.api(birthDate!),
            gender: gender,
            email: email.text.isEmpty ? null : email.text,
            phone: phone.text.isEmpty ? null : phone.text,
            preferredSide: preferredSide,
          );
      ref.invalidate(adminPlayersProvider);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Giocatore creato')),
        );
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('$error')));
      }
    }
    name.dispose();
    email.dispose();
    phone.dispose();
  }
}

class AdminCommunicationsScreen extends ConsumerWidget {
  const AdminCommunicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communications = ref.watch(adminCommunicationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunicazioni'),
        actions: const [AdminMenuButton()],
      ),
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
