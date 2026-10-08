import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../theme/app_theme.dart';

/// Mostra caricamento, errore con "Riprova" o i dati di un [AsyncValue].
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    required this.errorText,
    required this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  /// Cosa non si è riuscito a caricare, es. "Non riesco a caricare le partite".
  final String errorText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => value.when(
    data: data,
    loading: () => const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    ),
    error: (error, _) => ErrorCard(
      message: error is ApiException && error.statusCode != null
          ? '$errorText: ${error.message}'
          : '$errorText. Controlla la connessione.',
      onRetry: onRetry,
    ),
  );
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: context.colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Riprova')),
        ],
      ),
    ),
  );
}
