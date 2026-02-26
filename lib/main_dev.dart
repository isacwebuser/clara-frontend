import 'package:ecclesia_frontend/src/app.dart';
import 'package:ecclesia_frontend/src/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  final devConfig = AppConfig(
    environment: AppEnvironment.dev,
    appName: 'Ecclesia Dev',
    baseUrl: 'http://localhost:8080', // Or 10.0.2.2 for Android Emulator
  );

  runApp(
    ProviderScope(
      observers: const [AppProviderObserver()],
      overrides: [
        appConfigProvider.overrideWithValue(devConfig),
      ],
      child: const EcclesiaApp(),
    ),
  );
}
