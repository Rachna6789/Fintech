import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  return AccessibilityService();
});

class AccessibilityService {
  AccessibilityService();

  Future<void> announce(String message, {String? textDirection}) async {
    try {
      await SystemChannels.accessibility.send(message);
    } catch (_) {}
  }
}
