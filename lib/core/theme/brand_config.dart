import 'package:flutter/foundation.dart';

import 'app_colors.dart';

/// Aspetto dell'app per un circolo: colori, font e nome.
///
/// Oggi esiste solo [BrandConfig.crpadel]. Con il multi-circolo (Fase 0b)
/// arriverà dalla configurazione del circolo; ogni valore mancante resta
/// quello predefinito.
@immutable
class BrandConfig {
  const BrandConfig({
    required this.displayName,
    required this.lightColors,
    required this.darkColors,
    required this.headingFont,
    required this.bodyFont,
    required this.monoFont,
    required this.logoAsset,
  });

  final String displayName;
  final AppColors lightColors;
  final AppColors darkColors;
  final String headingFont;
  final String bodyFont;
  final String monoFont;

  /// Logo mostrato in accesso e splash (stesso del sito e dell'icona).
  final String logoAsset;

  static const crpadel = BrandConfig(
    displayName: 'CRPadel',
    lightColors: AppColors.light,
    darkColors: AppColors.dark,
    headingFont: 'Space Grotesk',
    bodyFont: 'Inter',
    monoFont: 'JetBrains Mono',
    logoAsset: 'assets/brand/crpadel_logo.png',
  );
}
