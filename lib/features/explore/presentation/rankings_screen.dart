import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../profile/domain/profile_models.dart';
import '../../profile/presentation/widgets/player_avatar.dart';
import 'explore_providers.dart';
import 'public_player_stats_screen.dart';

class RankingsScreen extends ConsumerStatefulWidget {
  const RankingsScreen({super.key});

  @override
  ConsumerState<RankingsScreen> createState() => _RankingsScreenState();
}

({String emoji, String name}) _challengeAnimal(String? level) =>
    switch (level) {
      'Altissimo' => (emoji: '🦁', name: 'Leone'),
      'Alto' => (emoji: '🐺', name: 'Lupo'),
      'Basso' => (emoji: '🦊', name: 'Volpe'),
      'Bassissimo' => (emoji: '🐰', name: 'Coniglio'),
      _ => (emoji: '', name: ''),
    };

enum _RankingView { general, monthly, decades, mostPlayed }

String _rankingSearchText(String value) {
  var normalized = value.toLowerCase();
  for (final entry in const {
    'a': '[àáâäãå]',
    'e': '[èéêë]',
    'i': '[ìíîï]',
    'o': '[òóôöõ]',
    'u': '[ùúûü]',
    'c': '[ç]',
  }.entries) {
    normalized = normalized.replaceAll(RegExp(entry.value), entry.key);
  }
  return normalized;
}

void _openPlayerStats(BuildContext context, PlayerRanking player) {
  if (player.playerRef == null || player.playerRef!.isEmpty) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PublicPlayerStatsScreen(player: player),
    ),
  );
}

class _RankingsScreenState extends ConsumerState<RankingsScreen> {
  late DateTime _month;
  _RankingView _view = _RankingView.general;
  bool _onlyEligible = false;
  String? _decadeStart;
  Timer? _summaryRefresh;
  final _generalSearch = TextEditingController();
  String _generalQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Il giocatore del mese si apre sull'ultimo mese concluso. In questo modo
    // nei primi giorni del mese non viene mostrata una classifica ancora vuota.
    _month = DateTime(now.year, now.month - 1);
    _summaryRefresh = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.invalidate(rankingMatchSummaryProvider);
      if (_view == _RankingView.mostPlayed) {
        ref.invalidate(mostPlayedRankingsProvider);
      }
    });
  }

  @override
  void dispose() {
    _summaryRefresh?.cancel();
    _generalSearch.dispose();
    super.dispose();
  }

  String get _monthKey => DateFormat('yyyy-MM').format(_month);

  Future<void> _refresh() async {
    ref.invalidate(rankingMatchSummaryProvider);
    switch (_view) {
      case _RankingView.general:
        final _ = await ref.refresh(fullRankingsProvider.future);
      case _RankingView.monthly:
        final _ = await ref.refresh(monthlyRankingsProvider(_monthKey).future);
      case _RankingView.decades:
        final _ = await ref.refresh(
          decadeRankingsProvider(_decadeStart).future,
        );
      case _RankingView.mostPlayed:
        final _ = await ref.refresh(mostPlayedRankingsProvider.future);
    }
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();
    final firstMonth = DateTime(now.year - 2);
    // Non proporre mesi futuri: non possono contenere punti ranking e portano
    // soltanto a una schermata vuota.
    final lastMonth = DateTime(now.year, now.month);
    final months = <DateTime>[];
    for (
      var month = lastMonth;
      !month.isBefore(firstMonth);
      month = DateTime(month.year, month.month - 1)
    ) {
      months.add(month);
    }
    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Seleziona il mese',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final selected =
                        month.year == _month.year &&
                        month.month == _month.month;
                    return ListTile(
                      title: Text(_monthLabel(month)),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle,
                              color: context.colors.primaryText,
                            )
                          : null,
                      selected: selected,
                      onTap: () => Navigator.pop(context, month),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _month = DateTime(selected.year, selected.month));
    }
  }

  Future<void> _selectDecade(DecadeRankingResult result) async {
    final selected = await showModalBottomSheet<RankingDecadePeriod>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Seleziona la decade',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: result.availablePeriods.length,
                  itemBuilder: (context, index) {
                    final period = result.availablePeriods[index];
                    final isSelected = period.start == result.periodStart;
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(_periodLabel(period.start, period.end)),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: context.colors.primaryText,
                            )
                          : null,
                      selected: isSelected,
                      onTap: () => Navigator.pop(context, period),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) setState(() => _decadeStart = selected.start);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Classifiche')),
    body: RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const _PlayedMatchesTotal(),
          const SizedBox(height: 16),
          SegmentedButton<_RankingView>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: _RankingView.general,
                icon: Icon(Icons.format_list_numbered, size: 18),
                label: Text('Generale'),
              ),
              ButtonSegment(
                value: _RankingView.monthly,
                icon: Icon(Icons.calendar_month_outlined, size: 18),
                label: Text('Mensile'),
              ),
              ButtonSegment(
                value: _RankingView.decades,
                icon: Icon(Icons.history, size: 18),
                label: Text('Decadi'),
              ),
            ],
            selected: _view == _RankingView.mostPlayed ? {} : {_view},
            onSelectionChanged: (selection) => selection.isEmpty
                ? null
                : setState(() => _view = selection.single),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() => _view = _RankingView.mostPlayed),
            icon: const Icon(Icons.emoji_events_outlined),
            label: const Text('Chi ha giocato di più'),
            style: _view == _RankingView.mostPlayed
                ? OutlinedButton.styleFrom(
                    backgroundColor: context.colors.primary.withValues(
                      alpha: .1,
                    ),
                    foregroundColor: context.colors.primaryText,
                    side: BorderSide(color: context.colors.primary),
                  )
                : null,
          ),
          const SizedBox(height: 20),
          if (_view == _RankingView.general) ...[
            Text(
              'Classifica generale',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Graduatoria ufficiale aggiornata',
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('general-player-search'),
              controller: _generalSearch,
              autocorrect: false,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _generalQuery = value),
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                labelText: 'Cerca giocatore',
                hintText: 'Nome o cognome',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _generalQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Cancella ricerca giocatore',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _generalSearch.clear();
                          setState(() => _generalQuery = '');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            AsyncValueView(
              value: ref.watch(fullRankingsProvider),
              errorText: 'Non riesco a caricare la classifica',
              onRetry: () => ref.invalidate(fullRankingsProvider),
              data: (players) {
                final terms = _rankingSearchText(
                  _generalQuery,
                ).trim().split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
                final matches = players.indexed
                    .where(
                      (entry) => terms.every(
                        (term) => _rankingSearchText(
                          entry.$2.playerName,
                        ).contains(term),
                      ),
                    )
                    .toList();
                if (players.isEmpty) {
                  return const Center(
                    child: Text('Nessun giocatore in classifica'),
                  );
                }
                if (matches.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Nessun giocatore trovato. Prova un altro nome o cognome.',
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (terms.isNotEmpty) ...[
                      Text(
                        '${matches.length} di ${players.length} giocatori',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                    ],
                    for (final entry in matches) ...[
                      _RankingRow(
                        player: entry.$2,
                        position: entry.$2.position > 0
                            ? entry.$2.position
                            : entry.$1 + 1,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ] else if (_view == _RankingView.monthly) ...[
            _MonthlyHeader(month: _month, onSelectMonth: _selectMonth),
            const SizedBox(height: 12),
            _MonthlyFilters(
              onlyEligible: _onlyEligible,
              onOnlyEligibleChanged: (value) =>
                  setState(() => _onlyEligible = value),
            ),
            const SizedBox(height: 12),
            AsyncValueView(
              value: ref.watch(monthlyRankingsProvider(_monthKey)),
              errorText: 'Non riesco a caricare la classifica mensile',
              onRetry: () => ref.invalidate(monthlyRankingsProvider(_monthKey)),
              data: (result) => _MonthlyRankingSection(
                result: result,
                onlyEligible: _onlyEligible,
              ),
            ),
          ] else if (_view == _RankingView.mostPlayed) ...[
            AsyncValueView(
              value: ref.watch(mostPlayedRankingsProvider),
              errorText: 'Non riesco a caricare le presenze Ranking',
              onRetry: () => ref.invalidate(mostPlayedRankingsProvider),
              data: (result) => _MostPlayedSection(result: result),
            ),
          ] else ...[
            AsyncValueView(
              value: ref.watch(decadeRankingsProvider(_decadeStart)),
              errorText: 'Non riesco a caricare le classifiche delle decadi',
              onRetry: () =>
                  ref.invalidate(decadeRankingsProvider(_decadeStart)),
              data: (result) => _DecadeRankingSection(
                result: result,
                onSelectPeriod: () => _selectDecade(result),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _MostPlayedSection extends ConsumerStatefulWidget {
  const _MostPlayedSection({required this.result});
  final MostPlayedRankingResult result;

  @override
  ConsumerState<_MostPlayedSection> createState() => _MostPlayedSectionState();
}

class _MostPlayedSectionState extends ConsumerState<_MostPlayedSection> {
  final _search = TextEditingController();
  String _query = '';
  MostPlayedSort _order = MostPlayedSort.matchesPlayed;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openPlayer(MostPlayedPlayer player) {
    final reference = player.playerRef;
    if (reference == null || reference.isEmpty) return;
    PlayerRanking? general;
    for (final candidate
        in ref.read(fullRankingsProvider).asData?.value ?? <PlayerRanking>[]) {
      if (candidate.playerRef == (player.ranking?.playerRef ?? reference)) {
        general = candidate;
        break;
      }
    }
    final selected =
        (general ?? player.ranking ?? PlayerRanking(playerName: player.name))
            .copyWith(
              playerRef: reference,
              playerName: player.name,
              playerPhotoUrl: player.photoUrl,
              matchesPlayed: player.matchesPlayed,
              matchesWon: player.wins,
            );
    _openPlayerStats(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    final terms = _query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty);
    final ordered = sortMostPlayedPlayers(widget.result.players, _order);
    final positions = {
      for (var i = 0; i < ordered.length; i++)
        ordered[i]: _order == MostPlayedSort.matchesPlayed
            ? ordered[i].position
            : i + 1,
    };
    final players = ordered
        .where(
          (player) =>
              terms.every((term) => player.name.toLowerCase().contains(term)),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Classifica presenze Ranking',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('attendance-player-search'),
          controller: _search,
          autocorrect: false,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            labelText: 'Cerca un giocatore',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Cancella ricerca',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<MostPlayedSort>(
          key: const ValueKey('attendance-sort'),
          initialValue: _order,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Ordina per',
            prefixIcon: Icon(Icons.sort),
          ),
          items: const [
            DropdownMenuItem(
              value: MostPlayedSort.matchesPlayed,
              child: Text('Partite giocate'),
            ),
            DropdownMenuItem(
              value: MostPlayedSort.underdogDescending,
              child: Text('Da sfavorito: % più alta'),
            ),
            DropdownMenuItem(
              value: MostPlayedSort.underdogAscending,
              child: Text('Da sfavorito: % più bassa'),
            ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _order = value);
          },
        ),
        const SizedBox(height: 6),
        Text(
          'Partite, vittorie e sconfitte comprendono lo storico. Set e game si riferiscono ai risultati dettagliati disponibili. Il tie-break decisivo vale un set, senza aggiungere game.',
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
        ),
        const SizedBox(height: 14),
        if (widget.result.players.isEmpty)
          const Text('Nessuna partita Ranking giocata.'),
        if (players.isEmpty && widget.result.players.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Nessun giocatore trovato'),
          ),
        for (final player in players) ...[
          Material(
            color: context.colors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: positions[player] == 1
                    ? context.colors.primary.withValues(alpha: .5)
                    : context.colors.border,
              ),
            ),
            child: InkWell(
              onTap: player.playerRef == null || player.playerRef!.isEmpty
                  ? null
                  : () => _openPlayer(player),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${positions[player]}°',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: context.colors.primaryText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        PlayerAvatar(
                          name: player.name,
                          photoUrl: player.photoUrl,
                          size: 34,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            player.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              '${player.matchesPlayed}',
                              style: context.fonts
                                  .monoStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  )
                                  .copyWith(color: context.colors.primaryText),
                            ),
                            const Text(
                              'PARTITE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Spirito di sfida',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Tooltip(
                          message:
                              'Percentuale di partite giocate da sfavorito sul totale con coefficienti documentati. 🦁 Leone: affronta le sfide più difficili (Altissimo da 70%). 🐺 Lupo: non teme avversari più forti (Alto da 50%). 🦊 Volpe: sceglie le sue sfide con astuzia (Basso da 30%). 🐰 Coniglio: preferisce partire da favorito (Bassissimo sotto 30%). Il risultato non cambia questa percentuale.',
                          child: Icon(Icons.info_outline, size: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (player.underdogMatchPercentage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: .05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ExcludeSemantics(
                              child: Container(
                                width: 68,
                                height: 68,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withValues(
                                    alpha: .1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _challengeAnimal(
                                    player.difficultyLevel,
                                  ).emoji,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _challengeAnimal(
                                      player.difficultyLevel,
                                    ).name,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: context.colors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${NumberFormat('0.#', 'it_IT').format(player.underdogMatchPercentage)}% — ${player.difficultyLevel}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text('Non disponibile'),
                    const SizedBox(height: 5),
                    Text(
                      player.matchesWithCoefficients > 0
                          ? '${player.underdogMatches} da sfavorito su ${player.matchesWithCoefficients} ${player.matchesWithCoefficients == 1 ? 'partita' : 'partite'} con coefficienti'
                          : 'Nessuna partita con coefficienti documentati',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final pair in [
                      ('Vittorie', player.wins, 'Sconfitte', player.losses),
                      (
                        'Set vinti',
                        player.setsWon,
                        'Set persi',
                        player.setsLost,
                      ),
                      (
                        'Game vinti',
                        player.gamesWon,
                        'Game persi',
                        player.gamesLost,
                      ),
                      (
                        'Tie-break giocati',
                        player.tiebreaksPlayed,
                        'Tie-break vinti',
                        player.tiebreaksWon,
                      ),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${pair.$1}  ${pair.$2}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${pair.$3}  ${pair.$4}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Set, game e tie-break: ${player.matchesWithScore} partite con dettaglio',
                            style: TextStyle(
                              fontSize: 10,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                        if (player.playerRef != null &&
                            player.playerRef!.isNotEmpty)
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: context.colors.primaryText,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PlayedMatchesTotal extends ConsumerWidget {
  const _PlayedMatchesTotal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(rankingMatchSummaryProvider);
    final data = summary.asData?.value;
    final since = data == null
        ? null
        : DateFormat('d MMMM yyyy', 'it_IT').format(DateTime.parse(data.since));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.colors.primary.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.sports_tennis, color: context.colors.primaryText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PARTITE GIOCATE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ranking con risultato${since == null ? '' : '\nDal $since'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textSecondary,
                  ),
                ),
                if (summary.hasError)
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(rankingMatchSummaryProvider),
                    child: const Text('Riprova'),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            liveRegion: true,
            child: Text(
              data == null
                  ? '—'
                  : NumberFormat.decimalPattern(
                      'it_IT',
                    ).format(data.totalPlayed),
              style: context.fonts
                  .monoStyle(fontSize: 38, fontWeight: FontWeight.w900)
                  .copyWith(color: context.colors.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecadeRankingSection extends StatelessWidget {
  const _DecadeRankingSection({
    required this.result,
    required this.onSelectPeriod,
  });

  final DecadeRankingResult result;
  final VoidCallback onSelectPeriod;

  @override
  Widget build(BuildContext context) {
    if (result.periodStart.isEmpty) {
      return const Center(
        child: Text('Nessuna classifica storica disponibile'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Classifiche delle decadi',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Classifica di chiusura per le decadi concluse; chiusura precedente per la decade in corso.',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onSelectPeriod,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            alignment: Alignment.centerLeft,
          ),
          icon: const Icon(Icons.history, size: 19),
          label: Text(_periodLabel(result.periodStart, result.periodEnd)),
        ),
        const SizedBox(height: 10),
        Card(
          color: context.colors.primaryTint,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.periodClosed ? 'Decade conclusa' : 'Decade in corso',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'Fotografia ufficiale congelata al ${_dateLabel(result.frozenAt)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  result.periodClosed
                      ? 'Risultati definitivi alla chiusura della decade. Soglia della fotografia: ${result.minimumMatches} partite.'
                      : 'La decade non è ancora conclusa: sono mostrati i risultati della decade precedente. Soglia della fotografia: ${result.minimumMatches} partite.',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (result.players.isEmpty)
          Center(
            child: Text(
              result.snapshotAvailable
                  ? 'Nessun giocatore in questa classifica'
                  : 'Fotografia di chiusura non disponibile per questa decade.',
            ),
          )
        else
          for (var index = 0; index < result.players.length; index++) ...[
            _DecadeRankingRow(
              player: result.players[index],
              position: result.players[index].position > 0
                  ? result.players[index].position
                  : index + 1,
            ),
            if (index < result.players.length - 1) const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _DecadeRankingRow extends StatelessWidget {
  const _DecadeRankingRow({required this.player, required this.position});

  final DecadeRankingPlayer player;
  final int position;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => _openPlayerStats(
        context,
        PlayerRanking(
          playerRef: player.playerRef,
          playerName: player.playerName,
          position: position,
          rankingBandName: player.rankingBandName,
          rankingBandColor: player.rankingBandColor,
          playerPhotoUrl: player.playerPhotoUrl,
          eloScore: player.eloScore,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Text(
                '#$position',
                style: context.fonts.monoStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: _color(player.rankingBandColor),
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.border),
              ),
            ),
            const SizedBox(width: 10),
            PlayerAvatar(
              name: player.playerName,
              photoUrl: player.playerPhotoUrl,
              size: 32,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.playerName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${player.rankingBandName ?? 'Senza fascia'} · coeff. ${player.coefficient.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              player.eloScore.toStringAsFixed(1),
              style: context.fonts
                  .monoStyle(fontWeight: FontWeight.w700)
                  .copyWith(color: context.colors.primaryText),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MonthlyHeader extends StatelessWidget {
  const _MonthlyHeader({required this.month, required this.onSelectMonth});

  final DateTime month;
  final VoidCallback onSelectMonth;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Classifica mensile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Migliori giocatori del mese',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
      OutlinedButton.icon(
        onPressed: onSelectMonth,
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
        icon: const Icon(Icons.calendar_month_outlined, size: 18),
        label: Text(_monthLabel(month)),
      ),
    ],
  );
}

class _MonthlyFilters extends StatelessWidget {
  const _MonthlyFilters({
    required this.onlyEligible,
    required this.onOnlyEligibleChanged,
  });

  final bool onlyEligible;
  final ValueChanged<bool> onOnlyEligibleChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      FilterChip(
        selected: onlyEligible,
        avatar: Icon(
          onlyEligible ? Icons.verified : Icons.verified_outlined,
          size: 18,
        ),
        label: const Text('Solo idonei'),
        onSelected: onOnlyEligibleChanged,
      ),
    ],
  );
}

class _MonthlyRankingSection extends StatelessWidget {
  const _MonthlyRankingSection({
    required this.result,
    required this.onlyEligible,
  });

  final MonthlyRankingResult result;
  final bool onlyEligible;

  @override
  Widget build(BuildContext context) {
    final players =
        result.players
            .where((player) => !onlyEligible || player.playerOfMonthEligible)
            .toList()
          ..sort((left, right) {
            final byDelta = right.classificationDelta.compareTo(
              left.classificationDelta,
            );
            if (byDelta != 0) return byDelta;
            final byPoints = right.pointsEarned.compareTo(left.pointsEarned);
            if (byPoints != 0) return byPoints;
            return left.playerName.compareTo(right.playerName);
          });
    final eligible = players
        .where((player) => player.playerOfMonthEligible)
        .toList();
    final winner = eligible.firstOrNull;
    if (players.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: context.colors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                onlyEligible
                    ? 'Nessun giocatore idoneo nel mese'
                    : 'Nessun punto ranking assegnato nel mese',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Servono almeno 3 partite nel mese per comparire',
          style: TextStyle(fontSize: 12, color: context.colors.primaryText),
        ),
        const SizedBox(height: 10),
        if (winner != null) ...[
          Card(
            color: const Color(0xFFFFC107).withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PlayerAvatar(
                    name: winner.playerName,
                    photoUrl: winner.playerPhotoUrl,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GIOCATORE DEL MESE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: context.colors.primaryText,
                          ),
                        ),
                        Text(
                          winner.playerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${winner.matchesPlayed} partite · ${winner.matchesWon} vinte',
                          style: TextStyle(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _signedPoints(winner.classificationDelta),
                    style: context.fonts
                        .monoStyle(fontSize: 18, fontWeight: FontWeight.w700)
                        .copyWith(color: const Color(0xFFFFB300)),
                  ),
                ],
              ),
            ),
          ),
        ] else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nessun giocatore ha ancora raggiunto tutti i requisiti per il Player del mese.',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
          ),
        const SizedBox(height: 8),
        for (final entry in players.indexed) ...[
          Builder(
            builder: (context) {
              final player = entry.$2;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 34,
                        child: Text(
                          '#${entry.$1 + 1}',
                          style: context.fonts.monoStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      PlayerAvatar(
                        name: player.playerName,
                        photoUrl: player.playerPhotoUrl,
                        size: 34,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    player.playerName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (player.playerOfMonthEligible) ...[
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.verified,
                                    size: 15,
                                    color: Colors.green,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '${player.matchesPlayed} PG · ${player.matchesWon} V · ${_points(player.pointsEarned)} PR · Δ ${_signedPoints(player.classificationDelta)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _signedPoints(player.classificationDelta),
                        style: context.fonts
                            .monoStyle(fontWeight: FontWeight.w700)
                            .copyWith(color: context.colors.primaryText),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

String _signedPoints(double value) =>
    '${value > 0 ? '+' : ''}${_points(value)}';

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.player, required this.position});
  final PlayerRanking player;
  final int position;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => _openPlayerStats(context, player),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Text(
                '#$position',
                style: context.fonts.monoStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: _color(player.rankingBandColor),
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.border),
              ),
            ),
            const SizedBox(width: 10),
            PlayerAvatar(
              name: player.playerName,
              photoUrl: player.playerPhotoUrl,
              size: 34,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.playerName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${player.matchesPlayed} PG · ${player.matchesWon} V',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  if (player.recentForm.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    _RecentForm(results: player.recentForm),
                  ],
                ],
              ),
            ),
            Text(
              player.eloScore.toStringAsFixed(1),
              style: context.fonts
                  .monoStyle(fontWeight: FontWeight.w700)
                  .copyWith(color: context.colors.primaryText),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RecentForm extends StatelessWidget {
  const _RecentForm({required this.results});

  final List<String> results;

  @override
  Widget build(BuildContext context) {
    final visible = results
        .where((result) => result == 'V' || result == 'S')
        .take(5)
        .toList();
    return Semantics(
      label: 'Forma ultime partite: ${visible.join(', ')}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ultime ${visible.length}',
            style: TextStyle(fontSize: 10, color: context.colors.textSecondary),
          ),
          const SizedBox(width: 5),
          for (final result in visible) ...[
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: result == 'V'
                    ? Colors.green.withValues(alpha: .14)
                    : Colors.red.withValues(alpha: .12),
                border: Border.all(
                  color: result == 'V'
                      ? Colors.green.withValues(alpha: .45)
                      : Colors.red.withValues(alpha: .4),
                ),
              ),
              child: Text(
                result,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: result == 'V' ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}

String _monthLabel(DateTime value) {
  final label = DateFormat('MMMM yyyy', 'it_IT').format(value);
  return '${label[0].toUpperCase()}${label.substring(1)}';
}

String _periodLabel(String start, String end) {
  final startDate = DateTime.tryParse(start);
  final endDate = DateTime.tryParse(end);
  if (startDate == null || endDate == null) return '$start – $end';
  final startLabel = DateFormat('d MMM', 'it_IT').format(startDate);
  final endLabel = DateFormat('d MMMM yyyy', 'it_IT').format(endDate);
  return '$startLabel – $endLabel';
}

String _dateLabel(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : DateFormat('d MMMM yyyy', 'it_IT').format(date);
}

String _points(double value) => NumberFormat('0.0', 'it_IT').format(value);

Color _color(String? value) {
  final hex = value?.replaceFirst('#', '');
  if (hex == null || hex.length != 6) return Colors.white;
  final parsed = int.tryParse('FF$hex', radix: 16);
  return parsed == null ? Colors.white : Color(parsed);
}
