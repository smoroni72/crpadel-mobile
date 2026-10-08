import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Segnaposto del logo finché non arriva quello definitivo.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppTheme.navy,
      borderRadius: BorderRadius.circular(size / 4),
    ),
    alignment: Alignment.center,
    child: Text(
      'CR',
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.375,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
