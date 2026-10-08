import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'brand_config.dart';

/// Font in uso, letti con `context.fonts`.
@immutable
class AppFonts extends ThemeExtension<AppFonts> {
  const AppFonts({required this.heading, required this.mono});

  final String heading;
  final String mono;

  /// Stile per orari, punteggi e numeri.
  TextStyle monoStyle({double? fontSize, FontWeight? fontWeight}) => TextStyle(
    fontFamily: mono,
    fontSize: fontSize,
    fontWeight: fontWeight ?? FontWeight.w500,
  );

  @override
  AppFonts copyWith({String? heading, String? mono}) =>
      AppFonts(heading: heading ?? this.heading, mono: mono ?? this.mono);

  @override
  AppFonts lerp(AppFonts? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppFonts get fonts => Theme.of(this).extension<AppFonts>()!;
}

abstract final class AppTheme {
  static const cardRadius = 16.0;
  static const controlRadius = 12.0;

  static ThemeData light([BrandConfig brand = BrandConfig.crpadel]) =>
      build(brand, Brightness.light);

  static ThemeData dark([BrandConfig brand = BrandConfig.crpadel]) =>
      build(brand, Brightness.dark);

  static ThemeData build(BrandConfig brand, Brightness brightness) {
    final c = brightness == Brightness.light
        ? brand.lightColors
        : brand.darkColors;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: c.primary,
          brightness: brightness,
        ).copyWith(
          primary: c.primary,
          onPrimary: c.onPrimary,
          primaryContainer: c.primaryTint,
          onPrimaryContainer: c.primaryText,
          secondary: c.navy,
          onSecondary: c.onNavy,
          surface: c.surface,
          onSurface: c.text,
          onSurfaceVariant: c.textSecondary,
          outline: c.border,
          outlineVariant: c.divider,
        );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(controlRadius),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: brand.bodyFont,
    );
    final heading = TextStyle(fontFamily: brand.headingFont, color: c.text);
    final textTheme = base.textTheme
        .apply(bodyColor: c.text, displayColor: c.text)
        .copyWith(
          headlineLarge: heading.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: heading.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: heading.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: heading.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: heading.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
    // Lo stile del testo dei pulsanti sostituisce quello predefinito invece
    // di unirsi: deve portarsi dietro il font del brand.
    final buttonText = textTheme.labelLarge?.copyWith(
      fontFamily: brand.bodyFont,
      fontWeight: FontWeight.w600,
    );
    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      extensions: [
        c,
        AppFonts(heading: brand.headingFont, mono: brand.monoFont),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.divider, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: c.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          elevation: 0,
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: c.text,
          side: BorderSide(color: c.border),
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primaryText,
          minimumSize: const Size(44, 44),
          textStyle: buttonText,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: controlShape,
        side: BorderSide(color: c.border),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
