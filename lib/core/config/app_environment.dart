abstract final class AppEnvironment {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://test.crpadel.it/api/v1',
  );

  static const clubSlug = String.fromEnvironment(
    'CLUB_SLUG',
    defaultValue: 'crpadel',
  );
}
