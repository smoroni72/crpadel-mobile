import 'package:flutter/material.dart';

/// Colori del brand e del dominio (stati partita, griglia) che il
/// `ColorScheme` di Material non copre. Si leggono con `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryText,
    required this.primaryTint,
    required this.onPrimary,
    required this.navy,
    required this.onNavy,
    required this.text,
    required this.textSecondary,
    required this.background,
    required this.surface,
    required this.border,
    required this.divider,
    required this.matchOpen,
    required this.matchDone,
    required this.slotFree,
    required this.slotMatch,
    required this.slotBooked,
    required this.slotLesson,
    required this.slotTraining,
  });

  /// Rosso azione: pulsanti, tab attiva.
  final Color primary;

  /// Rosso per testo e icone su sfondo chiaro (o scuro nel tema scuro).
  final Color primaryText;

  /// Fondo tenue rosso: riquadri data, chip selezionati.
  final Color primaryTint;
  final Color onPrimary;

  /// Navy del brand: card in evidenza ed elementi "tuoi".
  final Color navy;
  final Color onNavy;
  final Color text;
  final Color textSecondary;
  final Color background;
  final Color surface;
  final Color border;
  final Color divider;
  final Color matchOpen;
  final Color matchDone;
  final Color slotFree;
  final Color slotMatch;
  final Color slotBooked;
  final Color slotLesson;
  final Color slotTraining;

  /// Valori di `docs/SPEC_SCHERMATE.md`.
  static const light = AppColors(
    primary: Color(0xFFE6392D),
    primaryText: Color(0xFFC42B20),
    primaryTint: Color(0xFFFDECEA),
    onPrimary: Color(0xFFFFFFFF),
    navy: Color(0xFF1B2A4A),
    onNavy: Color(0xFFFFFFFF),
    text: Color(0xFF1C2840),
    textSecondary: Color(0xFF5C6884),
    background: Color(0xFFF9FAFB),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFDADEE7),
    divider: Color(0xFFEDEFF3),
    matchOpen: Color(0xFF1D5FB8),
    matchDone: Color(0xFF5C6884),
    slotFree: Color(0xFFEEF7F1),
    slotMatch: Color(0xFFFBE3E1),
    slotBooked: Color(0xFFFBEFD5),
    slotLesson: Color(0xFFE1ECFA),
    slotTraining: Color(0xFFE6E4F8),
  );

  /// Tema scuro come la webapp CRPadel (nero neutro, `.dark` di
  /// `src/index.css`); testi e stati hanno contrasto almeno 4,5:1.
  static const dark = AppColors(
    primary: Color(0xFFE6392D),
    primaryText: Color(0xFFFF8A7F),
    primaryTint: Color(0xFF3A1C1A),
    onPrimary: Color(0xFFFFFFFF),
    // Il sito usa grigi neutri anche per gli elementi "tuoi".
    navy: Color(0xFF2E2E2E),
    onNavy: Color(0xFFFFFFFF),
    text: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFADADAD),
    background: Color(0xFF050505),
    surface: Color(0xFF141414),
    border: Color(0xFF383838),
    divider: Color(0xFF242424),
    matchOpen: Color(0xFF6EA8FF),
    matchDone: Color(0xFFADADAD),
    slotFree: Color(0xFF13241A),
    slotMatch: Color(0xFF3A1C1A),
    slotBooked: Color(0xFF362A12),
    slotLesson: Color(0xFF14264A),
    slotTraining: Color(0xFF231F48),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryText,
    Color? primaryTint,
    Color? onPrimary,
    Color? navy,
    Color? onNavy,
    Color? text,
    Color? textSecondary,
    Color? background,
    Color? surface,
    Color? border,
    Color? divider,
    Color? matchOpen,
    Color? matchDone,
    Color? slotFree,
    Color? slotMatch,
    Color? slotBooked,
    Color? slotLesson,
    Color? slotTraining,
  }) => AppColors(
    primary: primary ?? this.primary,
    primaryText: primaryText ?? this.primaryText,
    primaryTint: primaryTint ?? this.primaryTint,
    onPrimary: onPrimary ?? this.onPrimary,
    navy: navy ?? this.navy,
    onNavy: onNavy ?? this.onNavy,
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    matchOpen: matchOpen ?? this.matchOpen,
    matchDone: matchDone ?? this.matchDone,
    slotFree: slotFree ?? this.slotFree,
    slotMatch: slotMatch ?? this.slotMatch,
    slotBooked: slotBooked ?? this.slotBooked,
    slotLesson: slotLesson ?? this.slotLesson,
    slotTraining: slotTraining ?? this.slotTraining,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: mix(primary, other.primary),
      primaryText: mix(primaryText, other.primaryText),
      primaryTint: mix(primaryTint, other.primaryTint),
      onPrimary: mix(onPrimary, other.onPrimary),
      navy: mix(navy, other.navy),
      onNavy: mix(onNavy, other.onNavy),
      text: mix(text, other.text),
      textSecondary: mix(textSecondary, other.textSecondary),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      border: mix(border, other.border),
      divider: mix(divider, other.divider),
      matchOpen: mix(matchOpen, other.matchOpen),
      matchDone: mix(matchDone, other.matchDone),
      slotFree: mix(slotFree, other.slotFree),
      slotMatch: mix(slotMatch, other.slotMatch),
      slotBooked: mix(slotBooked, other.slotBooked),
      slotLesson: mix(slotLesson, other.slotLesson),
      slotTraining: mix(slotTraining, other.slotTraining),
    );
  }
}
