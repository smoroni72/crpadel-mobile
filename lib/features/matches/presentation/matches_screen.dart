import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_view.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonView(
    title: 'Partite',
    subtitle: 'Partecipa alle partite aperte e inserisci i risultati.',
    icon: Icons.sports_tennis_outlined,
  );
}
