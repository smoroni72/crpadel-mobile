import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/async_value_view.dart';
import '../data/admin_repository.dart';
import 'admin_providers.dart';
import 'admin_menu_button.dart';

class AdminPlayerDetailScreen extends ConsumerWidget {
  const AdminPlayerDetailScreen({
    super.key,
    required this.playerId,
    this.player,
  });
  final String playerId;
  final AdminPlayer? player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = adminPlayerStatisticsProvider(playerId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio giocatore'),
        actions: const [AdminMenuButton()],
      ),
      body: AsyncValueView(
        value: ref.watch(provider),
        errorText: 'Non riesco a caricare il dettaglio del giocatore',
        onRetry: () => ref.invalidate(provider),
        data: (statistics) => RefreshIndicator(
          onRefresh: () => ref.refresh(provider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (player != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player!.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (player!.email.isNotEmpty) Text(player!.email),
                        if (player!.phone.isNotEmpty) Text(player!.phone),
                        if (player!.birthDate.isNotEmpty)
                          Text('Data di nascita: ${_date(player!.birthDate)}'),
                        Text(
                          player!.status == 'member' ? 'Iscritto' : 'Ospite',
                        ),
                        Text(
                          '${player!.matches} PG ranking · ${player!.wins} V · ${player!.points.toStringAsFixed(2)} PR',
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                '${statistics.matches} partite · ${statistics.wins} vittorie · ${statistics.losses} sconfitte',
              ),
              const SizedBox(height: 20),
              Text(
                'Partite del giocatore',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (statistics.history.isEmpty)
                const Text('Nessuna partita presente nello storico.'),
              for (final match in statistics.history)
                Card(
                  child: ListTile(
                    title: Text('${_date(match.date)} · ${match.time}'),
                    subtitle: Text(
                      '${match.court}\n${match.players.join(' · ')}\n${match.pending
                          ? 'Risultato da inserire'
                          : match.score.isEmpty
                          ? 'Completata'
                          : match.score}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.pushNamed(
                      AppRoutes.matchDetail,
                      pathParameters: {'id': match.id},
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _date(String value) {
    final date = DateTime.tryParse(value);
    return date == null ? value : DateFormat('dd/MM/yyyy').format(date);
  }
}
