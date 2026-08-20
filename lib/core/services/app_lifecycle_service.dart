// ignore_for_file: unused_field

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_service.dart';
import 'crash_reporting_service.dart';
import 'image_cache_service.dart';

final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  return AppLifecycleService(
    ref.watch(analyticsServiceProvider),
    ref.watch(crashReportingServiceProvider),
    ref.watch(imageCacheServiceProvider),
  );
});

class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService(this._analytics, this._crash, this._imageCache) {
    WidgetsBinding.instance.addObserver(this);
  }

  final AnalyticsService _analytics;
  final CrashReportingService _crash;
  final ImageCacheService _imageCache;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _analytics.logEvent('lifecycle_change', parameters: {'state': state.toString()});
    _crash.log('AppLifecycle changed to $state');
    if (state == AppLifecycleState.paused) {
      _imageCache.clearMemoryCache();
    }
  }

  @override
  void didHaveMemoryPressure() {
    _imageCache.clearMemoryCache();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
