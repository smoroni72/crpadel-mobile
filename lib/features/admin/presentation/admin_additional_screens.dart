import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/padel_match.dart';
import '../../matches/presentation/widgets/connected_match_card.dart';
import '../data/admin_repository.dart';
import 'admin_providers.dart';
import 'admin_menu_button.dart';

class AdminMatchHistoryScreen extends ConsumerStatefulWidget {
  const AdminMatchHistoryScreen({super.key});

  @override
  ConsumerState<AdminMatchHistoryScreen> createState() =>
      _AdminMatchHistoryScreenState();
}

class _AdminMatchHistoryScreenState
    extends ConsumerState<AdminMatchHistoryScreen> {
  late DateTime from;
  late DateTime to;
  String? playerId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    from = DateTime(now.year, now.month, 1);
    to = now;
  }

  Future<List<PadelMatch>> _load() async {
    if (from.isAfter(to)) {
      throw const FormatException(
        'La data iniziale non può essere successiva a quella finale.',
      );
    }
    final matches = await ref.read(matchesRepositoryProvider).between(from, to);
    return matches.where((match) {
      final historic =
          match.status == MatchStatus.completed ||
          match.status == MatchStatus.pendingResult ||
          match.status == MatchStatus.notPlayed;
      if (!historic) return false;
      if (playerId == null) return true;
      return match.players.any((player) => player.clubPlayerId == playerId);
    }).toList()..sort((a, b) => b.start.compareTo(a.start));
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(adminPlayersProvider('')).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico partite'),
        actions: const [AdminMenuButton()],
      ),
      body: FutureBuilder<List<PadelMatch>>(
        key: ValueKey('${Dates.api(from)}-${Dates.api(to)}-$playerId'),
        future: _load(),
        builder: (context, snapshot) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DateFilter(
                            label: 'Dal',
                            value: from,
                            onChanged: (value) => setState(() => from = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateFilter(
                            label: 'Al',
                            value: to,
                            onChanged: (value) => setState(() => to = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Autocomplete<AdminPlayer>(
                      displayStringForOption: (player) => player.name,
                      optionsBuilder: (value) {
                        final query = value.text.trim().toLowerCase();
                        return players
                            .where((player) {
                              if (query.isEmpty) return true;
                              return player.name.toLowerCase().contains(
                                    query,
                                  ) ||
                                  player.email.toLowerCase().contains(query);
                            })
                            .take(12);
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) =>
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: controller,
                                builder: (context, value, _) => TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.search,
                                  onChanged: (_) {
                                    if (playerId != null) {
                                      setState(() => playerId = null);
                                    }
                                  },
                                  onSubmitted: (_) => onSubmitted(),
                                  decoration: InputDecoration(
                                    labelText: 'Giocatore',
                                    hintText: 'Scrivi nome o email',
                                    helperText: playerId == null
                                        ? 'Tutti i giocatori'
                                        : 'Filtro applicato',
                                    prefixIcon: const Icon(
                                      Icons.person_search_outlined,
                                    ),
                                    suffixIcon: value.text.isEmpty
                                        ? null
                                        : IconButton(
                                            tooltip: 'Mostra tutti',
                                            onPressed: () {
                                              controller.clear();
                                              focusNode.requestFocus();
                                              setState(() => playerId = null);
                                            },
                                            icon: const Icon(Icons.clear),
                                          ),
                                  ),
                                ),
                              ),
                      onSelected: (player) =>
                          setState(() => playerId = player.id),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (snapshot.hasError)
              _MessageCard('Impossibile caricare lo storico: ${snapshot.error}')
            else if ((snapshot.data ?? const []).isEmpty)
              const _MessageCard('Nessuna partita corrisponde ai filtri.')
            else
              for (final match in snapshot.data!) ...[
                ConnectedMatchCard(match: match, adminMode: true),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class _DateFilter extends StatelessWidget {
  const _DateFilter({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final selected = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 730)),
        locale: const Locale('it', 'IT'),
      );
      if (selected != null) onChanged(selected);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(Dates.numeric(value)),
    ),
  );
}

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final searchController = TextEditingController();
  var search = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(adminUsersProvider(search));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utenti'),
        actions: const [AdminMenuButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createUser(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuovo utente'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => setState(() => search = value),
              decoration: InputDecoration(
                labelText: 'Cerca nome o email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => search = searchController.text),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
          Expanded(
            child: users.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: _MessageCard('$error')),
              data: (items) => RefreshIndicator(
                onRefresh: () => ref.refresh(adminUsersProvider(search).future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final user = items[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            user.role == 'admin'
                                ? Icons.admin_panel_settings
                                : Icons.person_outline,
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(
                          '${user.email}\n${user.role == 'admin' ? 'Admin' : 'Utente'} · ${user.active ? 'Attivo' : 'Disattivato'}',
                        ),
                        isThreeLine: true,
                        trailing: Icon(
                          user.verified
                              ? Icons.verified_outlined
                              : Icons.mark_email_unread_outlined,
                        ),
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

  Future<void> _createUser(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final currentUser = ref.read(authControllerProvider).value!;
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController(text: 'Ranking.2026!');
    var role = 'user';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuovo utente'),
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
                  decoration: const InputDecoration(labelText: 'Email *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password iniziale *',
                  ),
                ),
                const SizedBox(height: 10),
                if (currentUser.isSuperAdmin)
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Ruolo'),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('Utente')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => role = value ?? 'user'),
                  )
                else
                  const InputDecorator(
                    decoration: InputDecoration(labelText: 'Ruolo'),
                    child: Text('Utente'),
                  ),
                const SizedBox(height: 10),
                const Text(
                  'Al primo accesso il server richiederà il cambio della password.',
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
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Crea'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .createUser(
            fullName: name.text,
            email: email.text,
            password: password.text,
            role: role,
            permissions: role == 'admin'
                ? const [
                    'matches',
                    'bookings',
                    'players',
                    'users',
                    'statistics',
                    'rankings',
                    'push_notifications',
                  ]
                : const [],
          );
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('Utente creato')));
      }
    } on ApiException catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
    name.dispose();
    email.dispose();
    password.dispose();
  }
}

class AdminStatisticsScreen extends ConsumerStatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  ConsumerState<AdminStatisticsScreen> createState() =>
      _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends ConsumerState<AdminStatisticsScreen> {
  late DateTime from;
  late DateTime to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    from = DateTime(now.year, now.month, 1);
    to = now;
  }

  Future<_ClubStatistics> _load() async {
    final results = await Future.wait([
      ref.read(matchesRepositoryProvider).between(from, to),
      ref.read(adminRepositoryProvider).bookings(),
      ref.read(adminRepositoryProvider).players(),
    ]);
    final matches = results[0] as List<PadelMatch>;
    final bookings = (results[1] as List<AdminBooking>)
        .where(
          (booking) =>
              booking.date.compareTo(Dates.api(from)) >= 0 &&
              booking.date.compareTo(Dates.api(to)) <= 0,
        )
        .toList();
    final players = results[2] as List<AdminPlayer>;
    return _ClubStatistics(
      matches: matches.length,
      completed: matches.where((m) => m.status == MatchStatus.completed).length,
      pending: matches
          .where((m) => m.status == MatchStatus.pendingResult)
          .length,
      bookings: bookings.where((b) => b.status != 'cancelled').length,
      cancellations: bookings.where((b) => b.status == 'cancelled').length,
      players: players.where((p) => p.status == 'member').length,
      rankingPlayers: players.where((p) => p.matches > 0).length,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Statistiche del circolo'),
      actions: const [AdminMenuButton()],
    ),
    body: FutureBuilder<_ClubStatistics>(
      key: ValueKey('${Dates.api(from)}-${Dates.api(to)}'),
      future: _load(),
      builder: (context, snapshot) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: _DateFilter(
                  label: 'Dal',
                  value: from,
                  onChanged: (value) => setState(() => from = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateFilter(
                  label: 'Al',
                  value: to,
                  onChanged: (value) => setState(() => to = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (snapshot.connectionState == ConnectionState.waiting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (snapshot.hasError)
            _MessageCard(
              'Impossibile caricare le statistiche: ${snapshot.error}',
            )
          else ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                _StatCard(
                  'Partite',
                  snapshot.data!.matches,
                  Icons.sports_tennis,
                ),
                _StatCard(
                  'Completate',
                  snapshot.data!.completed,
                  Icons.emoji_events_outlined,
                ),
                _StatCard(
                  'Risultati mancanti',
                  snapshot.data!.pending,
                  Icons.flag_outlined,
                ),
                _StatCard(
                  'Prenotazioni',
                  snapshot.data!.bookings,
                  Icons.calendar_month_outlined,
                ),
                _StatCard(
                  'Cancellazioni',
                  snapshot.data!.cancellations,
                  Icons.event_busy_outlined,
                ),
                _StatCard(
                  'Giocatori attivi',
                  snapshot.data!.players,
                  Icons.groups_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.leaderboard_outlined),
                title: const Text('Giocatori con attività ranking'),
                trailing: Text('${snapshot.data!.rankingPlayers}'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon);
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.primary),
          const Spacer(),
          Text('$value', style: Theme.of(context).textTheme.headlineSmall),
          Text(label, style: TextStyle(color: context.colors.textSecondary)),
        ],
      ),
    ),
  );
}

class _ClubStatistics {
  const _ClubStatistics({
    required this.matches,
    required this.completed,
    required this.pending,
    required this.bookings,
    required this.cancellations,
    required this.players,
    required this.rankingPlayers,
  });
  final int matches;
  final int completed;
  final int pending;
  final int bookings;
  final int cancellations;
  final int players;
  final int rankingPlayers;
}

class _MessageCard extends StatelessWidget {
  const _MessageCard(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Text(message)),
  );
}
