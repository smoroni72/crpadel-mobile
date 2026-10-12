import 'dart:ui';

/// "#E8C468" → colore; `null` se il formato non è valido.
Color? parseHexColor(String? hex) {
  final digits = hex?.replaceFirst('#', '');
  if (digits == null || digits.length != 6) return null;
  final value = int.tryParse(digits, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}
