import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('il tema usa i colori del sito CRPadel', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, AppTheme.red);
    expect(theme.scaffoldBackgroundColor, AppTheme.background);
  });
}
