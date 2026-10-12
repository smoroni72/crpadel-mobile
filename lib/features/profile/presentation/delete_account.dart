import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/account_deletion_repository.dart';
import '../../auth/presentation/auth_controller.dart';

/// Conferma ed elimina l'account, come sul sito. Finché il backend non ha
/// l'endpoint (lacuna n. 10) spiega che la funzione non è disponibile.
Future<void> confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(accountDeletionRepositoryProvider);
  final messenger = ScaffoldMessenger.of(context);
  if (repository == null) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina account'),
        content: const Text(
          "L'eliminazione dell'account dall'app non è ancora disponibile. "
          'Per chiederla scrivi alla segreteria del circolo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ho capito'),
          ),
        ],
      ),
    );
    return;
  }
  final password = await showDialog<String>(
    context: context,
    builder: (_) => const _DeleteDialog(),
  );
  if (password == null) return;
  try {
    await repository.deleteAccount(password: password);
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          e is ApiException ? e.message : 'Eliminazione non riuscita',
        ),
      ),
    );
    return;
  }
  await ref.read(authControllerProvider.notifier).logout();
  messenger.showSnackBar(
    const SnackBar(content: Text('Il tuo account è stato eliminato')),
  );
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog();

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AlertDialog(
      title: Text(
        'Elimina account',
        style: TextStyle(color: colors.primaryText),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sei sicuro di voler eliminare il tuo account?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              ),
              child: Text(
                "L'azione è irreversibile. Verranno cancellati il tuo account, "
                'le tue prenotazioni, la tua classifica e i tuoi dati personali.',
                style: TextStyle(color: colors.primaryText),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password per confermare',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: _password.text.isEmpty
              ? null
              : () => Navigator.pop(context, _password.text),
          style: TextButton.styleFrom(foregroundColor: colors.primaryText),
          child: const Text('Elimina'),
        ),
      ],
    );
  }
}
