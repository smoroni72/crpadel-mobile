import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/media_url.dart';
import '../../../core/widgets/async_value_view.dart';
import '../domain/explore_models.dart';
import 'explore_providers.dart';

class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Tornei')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(tournamentsProvider.future),
      child: AsyncValueView(
        value: ref.watch(tournamentsProvider),
        errorText: 'Non riesco a caricare i tornei',
        onRetry: () => ref.invalidate(tournamentsProvider),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Nessun torneo pubblicato'))
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _TournamentCard(items[index]),
              ),
      ),
    ),
  );
}

class _TournamentCard extends StatelessWidget {
  const _TournamentCard(this.item);
  final ClubTournament item;

  @override
  Widget build(BuildContext context) {
    final image = absoluteMediaUrl(item.imageUrl);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetail(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (image != null)
              Image.network(
                image,
                height: 145,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _Pill(_status(item.status)),
                      _Pill(_level(item.level)),
                      if (item.affectsRanking)
                        const _Pill('Vale per il ranking'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d MMMM yyyy', 'it_IT').format(item.startDate),
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  if (item.description?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 18),
                      const SizedBox(width: 6),
                      Text('${item.registeredPlayers} partecipanti'),
                      const Spacer(),
                      const Text('Dettagli'),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: context.colors.primaryTint,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: context.colors.primaryText,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

void _showDetail(BuildContext context, ClubTournament item) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      maxChildSize: .94,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _Detail('Stato', _status(item.status)),
          _Detail(
            'Data',
            DateFormat('d MMMM yyyy', 'it_IT').format(item.startDate),
          ),
          _Detail('Livello', _level(item.level)),
          _Detail('Formula', _type(item.type)),
          _Detail('Partecipanti', '${item.registeredPlayers}'),
          if (item.entryFee > 0)
            _Detail('Quota', '€ ${item.entryFee.toStringAsFixed(2)}'),
          if (item.prize?.trim().isNotEmpty == true)
            _Detail('Premio', item.prize!),
          if (item.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text('Descrizione', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(item.description!),
          ],
          if (item.rules?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text('Regolamento', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(item.rules!),
          ],
        ],
      ),
    ),
  );
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

String _status(String value) => switch (value) {
  'active' => 'In corso',
  'completed' => 'Completato',
  _ => 'Prossimamente',
};

String _level(String value) => switch (value) {
  'principiante' => 'Principiante',
  'intermedio' => 'Intermedio',
  'avanzato' => 'Avanzato',
  _ => 'Open',
};

String _type(String value) => switch (value) {
  'round_robin' => 'Girone',
  'americano' => 'Americano',
  _ => 'Eliminazione',
};
