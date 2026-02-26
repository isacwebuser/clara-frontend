import 'package:ecclesia_frontend/src/app.dart';
import 'package:ecclesia_frontend/src/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  final prodConfig = AppConfig(
    environment: AppEnvironment.prod,
    appName: 'Ecclesia',
    baseUrl: 'https://api.ecclesia.com', // Replace with real prod URL
  );

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(prodConfig),
      ],
      child: const EcclesiaApp(),
    ),
  );
}
