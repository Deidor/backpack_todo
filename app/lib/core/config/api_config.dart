abstract final class ApiConfig {
  // 10.0.2.2 is the host machine as seen from the Android emulator.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
