import 'package:flutter/services.dart';

/// Maschera `gg/mm/aaaa`: accetta solo cifre e inserisce le barre da sola,
/// così basta la tastiera numerica.
class DateInputFormatter extends TextInputFormatter {
  const DateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Cancellando subito dopo una barra si toglie anche la cifra prima.
    final deletedSlash =
        newValue.text.length < oldValue.text.length &&
        oldValue.text.endsWith('/') &&
        !newValue.text.endsWith('/');
    if (deletedSlash && digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.length > 8) digits = digits.substring(0, 8);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i == 1 || i == 3) && i < digits.length - 1) buffer.write('/');
    }
    var text = buffer.toString();
    // Barra automatica appena completati giorno o mese.
    final growing = newValue.text.length > oldValue.text.length;
    if (growing && (digits.length == 2 || digits.length == 4)) text += '/';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
