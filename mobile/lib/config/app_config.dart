class AppConfig {
  static const String appName = 'Job Coach';
  static const String appVersion = '0.1.0';

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const bool useMockServices = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: true,
  );
}
