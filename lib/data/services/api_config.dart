abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'BINGCOOK_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5115',
  );
}
