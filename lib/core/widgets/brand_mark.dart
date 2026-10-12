import 'package:flutter/material.dart';

import '../theme/brand_config.dart';

/// Logo del circolo, lo stesso del sito e dell'icona dell'app.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 96});

  /// Altezza del logo.
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    BrandConfig.crpadel.logoAsset,
    height: size,
    semanticLabel: BrandConfig.crpadel.displayName,
    filterQuality: FilterQuality.medium,
  );
}
