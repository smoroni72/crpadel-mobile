import 'package:crpadel_mobile/core/utils/date_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = DateInputFormatter();

  /// Simula la digitazione carattere per carattere.
  String type(String keys) {
    var value = TextEditingValue.empty;
    for (final key in keys.split('')) {
      final next = TextEditingValue(
        text: value.text + key,
        selection: TextSelection.collapsed(offset: value.text.length + 1),
      );
      value = formatter.formatEditUpdate(value, next);
    }
    return value.text;
  }

  String backspace(String text) => formatter
      .formatEditUpdate(
        TextEditingValue(text: text),
        TextEditingValue(text: text.substring(0, text.length - 1)),
      )
      .text;

  test('inserisce le barre mentre si digita', () {
    expect(type('0'), '0');
    expect(type('02'), '02/');
    expect(type('0212'), '02/12/');
    expect(type('02121990'), '02/12/1990');
  });

  test('ignora le cifre oltre l\'anno', () {
    expect(type('021219901'), '02/12/1990');
  });

  test('la cancellazione dopo una barra toglie anche la cifra', () {
    expect(backspace('02/'), '0');
    expect(backspace('02/12/'), '02/1');
    expect(backspace('02/12/19'), '02/12/1');
  });

  test('un testo incollato viene riformattato', () {
    final value = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '02121990'),
    );
    expect(value.text, '02/12/1990');
  });
}
