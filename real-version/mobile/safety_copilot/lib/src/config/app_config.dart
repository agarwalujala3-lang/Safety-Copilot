class AppConfig {
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com/api/v1',
  );

  static const String apiFallbackUrls = String.fromEnvironment(
    'API_FALLBACK_URLS',
    defaultValue:
        'https://yegajpcluzigy6ffamfvwopxry0ejyao.lambda-url.ap-south-1.on.aws/api/v1',
  );

  static bool get isProd => flavor == 'prod';

  static List<String> get allApiBaseUrls {
    final urls = <String>{
      apiBaseUrl.trim(),
      ...apiFallbackUrls
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    };
    return urls.toList(growable: false);
  }
}
