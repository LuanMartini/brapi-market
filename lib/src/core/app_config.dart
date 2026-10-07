abstract final class AppConfig {
  static const apiBaseUrl = 'https://brapi.dev/api';
  static const apiKey = String.fromEnvironment('BRAPI_API_KEY');
  static const defaultSymbols = <String>['PETR4', 'VALE3', 'ITUB4'];

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}
