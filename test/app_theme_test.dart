import 'package:crpadel_mobile/core/theme/app_colors.dart';
import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:crpadel_mobile/core/theme/brand_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('il tema chiaro usa i token di SPEC_SCHERMATE', () {
    final theme = AppTheme.light();
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, const Color(0xFFE6392D));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF9FAFB));
    expect(theme.extension<AppColors>(), AppColors.light);
    expect(theme.textTheme.headlineMedium?.fontFamily, 'Space Grotesk');
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
  });

  test('il tema scuro usa i colori scuri dello stesso brand', () {
    final theme = AppTheme.dark();
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.dark.background);
    expect(theme.extension<AppColors>(), AppColors.dark);
  });

  test('un brand diverso cambia colori e font', () {
    final brand = BrandConfig(
      displayName: 'Altro circolo',
      lightColors: AppColors.light.copyWith(primary: const Color(0xFF0A7D3B)),
      darkColors: AppColors.dark,
      headingFont: 'Inter',
      bodyFont: 'Inter',
      monoFont: 'JetBrains Mono',
    );
    final theme = AppTheme.light(brand);
    expect(theme.colorScheme.primary, const Color(0xFF0A7D3B));
    expect(theme.textTheme.headlineMedium?.fontFamily, 'Inter');
  });

  test('i pulsanti usano il font del brand', () {
    final theme = AppTheme.light();
    final styles = [
      theme.elevatedButtonTheme.style,
      theme.outlinedButtonTheme.style,
      theme.textButtonTheme.style,
    ];
    for (final style in styles) {
      expect(style?.textStyle?.resolve({})?.fontFamily, 'Inter');
    }
  });
}
