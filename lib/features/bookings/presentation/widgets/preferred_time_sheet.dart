import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/bookings_repository.dart';
import '../../data/preferred_time_repository.dart';
import '../../domain/booking_request.dart';
import '../book_providers.dart';

/// Pannello per scegliere la fascia oraria preferita.
Future<void> showPreferredTimeSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _PreferredTimeSheet(),
    );

class _PreferredTimeSheet extends ConsumerStatefulWidget {
  const _PreferredTimeSheet();

  @override
  ConsumerState<_PreferredTimeSheet> createState() =>
      _PreferredTimeSheetState();
}

class _PreferredTimeSheetState extends ConsumerState<_PreferredTimeSheet> {
  late final PreferredTime? _initial = ref.read(preferredTimeProvider).value;
  late int _start = _initial?.startMinutes ?? 19 * 60;
  late int _end = _initial?.endMinutes ?? 20 * 60;

  static final _times = [
    for (var m = openingMinutes; m < closingMinutes; m += 30) m,
  ];

  Future<void> _save(PreferredTime? value) async {
    await ref.read(preferredTimeProvider.notifier).set(value);
    if (mounted) Navigator.pop(context);
  }

  Widget _picker(String label, int value, ValueChanged<int> onChanged) =>
      Expanded(
        child: DropdownButtonFormField<int>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: [
            for (final m in _times)
              DropdownMenuItem(value: m, child: Text(hhmm(m))),
          ],
          onChanged: (v) => setState(() => onChanged(v!)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final valid = _end > _start;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Orario preferito',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Gli orari di inizio in questa fascia sono marcati con ★ nei campi '
            'liberi. La preferenza resta su questo telefono.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _picker('Dalle', _start, (v) => _start = v),
              const SizedBox(width: 12),
              _picker('Alle', _end, (v) => _end = v),
            ],
          ),
          if (!valid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "L'orario finale deve essere dopo quello iniziale",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: valid ? () => _save(PreferredTime(_start, _end)) : null,
            child: const Text('Salva'),
          ),
          if (_initial != null)
            TextButton(
              onPressed: () => _save(null),
              child: const Text('Rimuovi orario preferito'),
            ),
        ],
      ),
    );
  }
}
