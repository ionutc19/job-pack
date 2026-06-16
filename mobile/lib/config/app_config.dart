class AppConfig {
  static const String appName = 'Job Pack';
  static const String appVersion = '0.1.0';

  // Backend base URL — change for production or local dev
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Use mock services instead of real backend
  static const bool useMockServices = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: true,
  );
}
