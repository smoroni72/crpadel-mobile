import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
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
    final dayController = ref.read(matchesDayProvider.notifier);
    Future<void> refresh() async {
      await Future.wait<Object?>([
        if (mineOnly)
          ref.refresh(myUpcomingMatchesProvider.future)
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Text(
                'Partite',
                style: Theme.of(context).textTheme.headlineMedium,
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

class _MyMatches extends ConsumerWidget {
  const _MyMatches();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(myUpcomingMatchesProvider),
    errorText: 'Non riesco a caricare le tue partite',
    onRetry: () => ref.invalidate(myUpcomingMatchesProvider),
    data: (list) {
      if (list.isEmpty) {
        return const _Empty(
          'Non hai partite in programma. Prenota un campo o chiedi di '
          'entrare in una partita aperta.',
        );
      }
      // Raggruppate per giorno.
      final children = <Widget>[];
      DateTime? current;
      for (final match in list) {
        if (match.date != current) {
          current = match.date;
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
