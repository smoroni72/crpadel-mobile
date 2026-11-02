import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../app_menu/presentation/app_menu_provider.dart';
import '../domain/padel_match.dart';
import 'day_matches_provider.dart';
import 'match_providers.dart';
import 'widgets/connected_match_card.dart';
import 'widgets/day_strip.dart';

/// Tab Partite: le partite del giorno a tutta pagina, o solo le proprie.
class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mineOnly = ref.watch(mineOnlyProvider);
    final day = ref.watch(matchesDayProvider);
    final menuConfiguration = ref.watch(appMenuConfigurationProvider).value;
    final dayController = ref.read(matchesDayProvider.notifier);
    Future<void> refresh() async {
      await Future.wait<Object?>([
        if (mineOnly)
          ref.refresh(myMatchesProvider.future)
        else
          ref.refresh(dayMatchesProvider(day).future),
      ]).catchError((_) => <Object?>[]);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            // Lascia spazio alla barra di navigazione sovrapposta, anche quando
            // l'ultima card contiene squadre, coefficienti e azioni.
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 124),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Partite',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (menuConfiguration?.createMatches ?? true) ...[
                    FilledButton.icon(
                      onPressed: () => context.goNamed(
                        AppRoutes.book,
                        queryParameters: const {'mode': 'match'},
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Crea partita'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const ThemeToggleButton(),
                ],
              ),
              const SizedBox(height: 14),
              _Filter(
                mineOnly: mineOnly,
                onChanged: ref.read(mineOnlyProvider.notifier).set,
              ),
              const SizedBox(height: 14),
              if (mineOnly)
                const _MyMatches()
              else ...[
                DayStrip(
                  selected: day,
                  matchDates:
                      ref.watch(matchDatesProvider(day)).value ?? const {},
                  onSelected: dayController.select,
                  onPrevious: dayController.previous,
                  onNext: dayController.next,
                ),
                const SizedBox(height: 10),
                _DayMatches(day: day),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({required this.mineOnly, required this.onChanged});

  final bool mineOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<bool>(
    showSelectedIcon: false,
    segments: const [
      ButtonSegment(value: false, label: Text('Tutte')),
      ButtonSegment(value: true, label: Text('Le mie')),
    ],
    selected: {mineOnly},
    onSelectionChanged: (s) => onChanged(s.first),
  );
}

class _DayMatches extends ConsumerWidget {
  const _DayMatches({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(dayMatchesProvider(day)),
    errorText: 'Non riesco a caricare le partite',
    onRetry: () => ref.invalidate(dayMatchesProvider(day)),
    data: (list) => list.isEmpty
        ? const _Empty('Nessuna partita in programma')
        : _MatchList(matches: list),
  );
}

class _MyMatches extends ConsumerStatefulWidget {
  const _MyMatches();

  @override
  ConsumerState<_MyMatches> createState() => _MyMatchesState();
}

class _MyMatchesState extends ConsumerState<_MyMatches> {
  DateTime? _from;
  DateTime? _to;

  Future<void> _pickFrom() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime(DateTime.now().year, 1, 1),
      firstDate: DateTime(2020),
      lastDate: _to ?? DateTime(DateTime.now().year + 3, 12, 31),
      helpText: 'Partite dal',
      cancelText: 'Annulla',
      confirmText: 'Applica',
    );
    if (selected != null) setState(() => _from = selected);
  }

  Future<void> _pickTo() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: _from ?? DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 3, 12, 31),
      helpText: 'Partite fino al',
      cancelText: 'Annulla',
      confirmText: 'Applica',
    );
    if (selected != null) setState(() => _to = selected);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _pickFrom,
            icon: const Icon(Icons.calendar_today_outlined, size: 17),
            label: Text(_from == null ? 'Dal' : 'Dal ${Dates.numeric(_from!)}'),
          ),
          OutlinedButton.icon(
            onPressed: _pickTo,
            icon: const Icon(Icons.event_outlined, size: 17),
            label: Text(_to == null ? 'Al' : 'Al ${Dates.numeric(_to!)}'),
          ),
          if (_from != null || _to != null)
            TextButton.icon(
              onPressed: () => setState(() {
                _from = null;
                _to = null;
              }),
              icon: const Icon(Icons.clear, size: 17),
              label: const Text('Tutte le date'),
            ),
        ],
      ),
      const SizedBox(height: 12),
      AsyncValueView(
        value: ref.watch(myMatchesProvider),
        errorText: 'Non riesco a caricare le tue partite',
        onRetry: () => ref.invalidate(myMatchesProvider),
        data: (allMatches) {
          final list = allMatches.where((match) {
            final date = DateTime(
              match.date.year,
              match.date.month,
              match.date.day,
            );
            return (_from == null || !date.isBefore(_from!)) &&
                (_to == null || !date.isAfter(_to!));
          }).toList();
          if (list.isEmpty) {
            return const _Empty(
              'Non risultano tue partite nell’intervallo selezionato.',
            );
          }
          // Raggruppate per giorno, dalle più recenti alle più vecchie.
          final children = <Widget>[];
          String? current;
          for (final match in list) {
            final dateKey = Dates.api(match.date);
            if (dateKey != current) {
              current = dateKey;
              children.add(
                Padding(
                  padding: EdgeInsets.only(
                    top: children.isEmpty ? 0 : 8,
                    bottom: 8,
                  ),
                  child: Text(
                    Dates.longDay(match.date),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              );
            }
            children
              ..add(ConnectedMatchCard(match: match))
              ..add(const SizedBox(height: 10));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        },
      ),
    ],
  );
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.matches});

  final List<PadelMatch> matches;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final match in matches) ...[
        ConnectedMatchCard(match: match),
        const SizedBox(height: 10),
      ],
    ],
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Text(text, style: TextStyle(color: context.colors.textSecondary)),
    ),
  );
}
