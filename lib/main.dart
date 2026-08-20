import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'core/router/app_router.dart';
import 'core/services/firebase_initializer.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/crash_reporting_service.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();

  final container = ProviderContainer();
  // Initialize Crashlytics and set global error handlers
  await container.read(crashReportingServiceProvider).initialize();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };
  await container.read(hiveServiceProvider).initialize();
  await container.read(notificationServiceProvider).initialize();
  // Initialize lifecycle service so it starts observing
  container.read(appLifecycleServiceProvider);

  runApp(
    UncontrolledProviderScope(container: container, child: const FinTrackApp()),
  );
}

class FinTrackApp extends ConsumerWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final notificationService = ref.read(notificationServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationService.handlePendingInitialMessage();
    });

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = lightDynamic?.harmonized() ??
            ColorScheme.fromSeed(seedColor: AppTheme.seedColor, brightness: Brightness.light);
        final darkScheme = darkDynamic?.harmonized() ??
            ColorScheme.fromSeed(seedColor: AppTheme.seedColor, brightness: Brightness.dark);

        return MaterialApp.router(
          title: 'FinTrack',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: AppTheme.buildTheme(
            brightness: Brightness.light,
            dynamicScheme: lightScheme,
          ),
          darkTheme: AppTheme.buildTheme(
            brightness: Brightness.dark,
            dynamicScheme: darkScheme,
          ),
          routerConfig: router,
        );
      },
    );
  }
}
