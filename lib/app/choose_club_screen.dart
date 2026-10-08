import 'package:flutter/material.dart';

import '../core/widgets/brand_mark.dart';

/// Segnaposto della scelta del circolo (Fase 0b). Oggi non si raggiunge,
/// perché il circolo vale sempre `CLUB_SLUG`.
class ChooseClubScreen extends StatelessWidget {
  const ChooseClubScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandMark(),
          SizedBox(height: 24),
          Text('Scegli il tuo circolo'),
        ],
      ),
    ),
  );
}
