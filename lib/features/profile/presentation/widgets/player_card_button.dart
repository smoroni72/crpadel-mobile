import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../../../../core/providers.dart';
import '../../data/player_card_pdf.dart';
import '../../data/player_card_repository.dart';

class PlayerCardButton extends ConsumerStatefulWidget {
  const PlayerCardButton({super.key, this.playerId, this.compact = false});
  final String? playerId;
  final bool compact;
  @override
  ConsumerState<PlayerCardButton> createState() => _PlayerCardButtonState();
}

class _PlayerCardButtonState extends ConsumerState<PlayerCardButton> {
  bool _loading = false;
  Future<void> _open() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = await loadPlayerCardData(api, playerId: widget.playerId);
      final bytes = await createPlayerCardPdf(data);
      if (!mounted) return;
      final name = ((data['card'] as Map)['player'] as Map)['name'] as String;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Carta giocatore PDF')),
            body: PdfPreview(
              build: (_) async => bytes,
              pdfFileName: playerCardFilename(name),
              initialPageFormat: PdfPageFormat.a4,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              onError: (_, _) => const Center(
                child: Text('Non riesco a visualizzare il PDF. Riprova.'),
              ),
            ),
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Non riesco a preparare la carta giocatore. Riprova.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.compact
      ? IconButton(
          onPressed: _loading ? null : _open,
          tooltip: 'Carta giocatore PDF',
          icon: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
        )
      : OutlinedButton.icon(
          onPressed: _loading ? null : _open,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Carta giocatore PDF · stampa e condividi'),
        );
}
