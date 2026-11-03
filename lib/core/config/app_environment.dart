abstract final class AppEnvironment {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://crpadel.it/api/v1',
  );

  static const clubSlug = String.fromEnvironment(
    'CLUB_SLUG',
    defaultValue: 'crpadel',
  );

  /// Fasce orarie e movimenti del pacchetto simulati (lacuna n. 2).
  static const fakeSubscriptionDetails = bool.fromEnvironment(
    'FAKE_SUBSCRIPTION_DETAILS',
  );
}
