import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  AnalyticsService() : _analytics = FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters?.cast<String, Object>(),
      );
    } catch (_) {}
  }

  Future<void> setUserId(String? id) async {
    try {
      await _analytics.setUserId(id: id);
    } catch (_) {}
  }
}
