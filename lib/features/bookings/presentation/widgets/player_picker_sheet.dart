import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../matches/domain/directory_player.dart';
import '../book_providers.dart';

/// Cerca un giocatore nella rubrica del circolo. [excluded] sono gli id già
/// scelti; l'utente stesso si aggiunge con "Gioco anch'io".
Future<DirectoryPlayer?> showPlayerPicker(
  BuildContext context, {
  required Set<String> excluded,
}) => showModalBottomSheet<DirectoryPlayer>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _PlayerPicker(excluded: excluded),
);

class _PlayerPicker extends ConsumerStatefulWidget {
  const _PlayerPicker({required this.excluded});

  final Set<String> excluded;

  @override
  ConsumerState<_PlayerPicker> createState() => _PlayerPickerState();
}

class _PlayerPickerState extends ConsumerState<_PlayerPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final directory = ref.watch(playersDirectoryProvider);
    final colors = context.colors;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Cerca un giocatore',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            Expanded(
              child: AsyncValueView(
                value: directory,
                errorText: 'Non riesco a caricare i giocatori',
                onRetry: () => ref.invalidate(playersDirectoryProvider),
                data: (all) {
                  final q = _query.toLowerCase();
                  final players = [
                    for (final p in all)
                      if (!p.isSelf &&
                          !widget.excluded.contains(p.id) &&
                          p.fullName.toLowerCase().contains(q))
                        p,
                  ];
                  if (players.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Nessun giocatore trovato'),
                    );
                  }
                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, i) {
                      final p = players[i];
                      return ListTile(
                        minTileHeight: 56,
                        leading: CircleAvatar(
                          backgroundColor: colors.divider,
                          foregroundColor: colors.text,
                          child: Text(initials(p.fullName)),
                        ),
                        title: Text(p.fullName),
                        subtitle: p.rankingBandName == null
                            ? null
                            : Text('Fascia ${p.rankingBandName}'),
                        onTap: () => Navigator.pop(context, p),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Mario Rossi" → "MR".
String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}
