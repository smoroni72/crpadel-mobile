import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_view.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonView(
    title: 'Prenota',
    subtitle: 'Scegli giorno, orario e campo disponibile.',
    icon: Icons.calendar_month_outlined,
  );
}
