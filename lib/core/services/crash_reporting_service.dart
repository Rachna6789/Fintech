import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return CrashReportingService();
});

class CrashReportingService {
  CrashReportingService();

  Future<void> initialize() async {
    // Ensure Crashlytics collection is enabled in production.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  Future<void> recordError(Object error, StackTrace stack,
      {String? reason}) async {
    try {
      await FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
    } catch (_) {}
  }

  Future<void> log(String message) async {
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }
}
