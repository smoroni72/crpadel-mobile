import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../domain/padel_match.dart';
import '../match_providers.dart';
import 'match_card.dart';

/// [MatchCard] collegata al dettaglio e a "Partecipa".
class ConnectedMatchCard extends ConsumerWidget {
  const ConnectedMatchCard({super.key, required this.match});

  final PadelMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authControllerProvider).value?.id ?? '';
    return MatchCard(
      match: match,
      myUserId: userId,
      onTap: () => context.pushNamed(
        AppRoutes.matchDetail,
        pathParameters: {'id': match.id},
      ),
      onCancel: match.isOrganizer(userId) && match.status == MatchStatus.open
          ? () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Annullare la partita?'),
                  content: const Text(
                    'La partita verrà annullata. La prenotazione del campo '
                    'resterà attiva e potrai annullarla separatamente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No, tienila'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Annulla partita'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              final error = await ref
                  .read(matchActionsProvider)
                  .cancel(match.id);
              messenger.showSnackBar(
                SnackBar(content: Text(error ?? 'Partita annullata')),
              );
            }
          : null,
      onJoin: () async {
        final messenger = ScaffoldMessenger.of(context);
        final error = await ref.read(matchActionsProvider).join(match);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              error ??
                  'Sei nella partita delle ${match.slot?.startLabel ?? ''}',
            ),
          ),
        );
      },
    );
  }
}
