import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/brand_config.dart';
import '../../../core/widgets/async_value_view.dart';
import 'explore_providers.dart';

class ClubInfoScreen extends ConsumerWidget {
  const ClubInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Informazioni sul circolo')),
    body: AsyncValueView(
      value: ref.watch(clubInfoProvider),
      errorText: 'Non riesco a caricare le informazioni del circolo',
      onRetry: () => ref.invalidate(clubInfoProvider),
      data: (club) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Center(child: Image.asset(BrandConfig.crpadel.logoAsset, height: 96)),
          const SizedBox(height: 18),
          Text(
            club.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Il tuo circolo di padel: prenotazioni, partite, tornei, '
            'classifica e attività della community in un solo posto.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 24),
          _InfoRow(Icons.language, 'Sito', 'crpadel.it'),
          _InfoRow(Icons.mail_outline, 'Email', 'info@crpadel.it'),
          _InfoRow(Icons.public, 'Fuso orario', club.timezone),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Indirizzo, telefono e orari saranno mostrati qui quando '
                'verranno configurati dal circolo.',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: context.colors.primaryText),
      title: Text(label),
      subtitle: Text(value),
    ),
  );
}
