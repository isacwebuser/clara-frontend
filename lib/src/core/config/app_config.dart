import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment {
  dev,
  prod,
}

class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String baseUrl;

  AppConfig({
    required this.environment,
    required this.appName,
    required this.baseUrl,
  });
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be overridden in main.dart');
});
