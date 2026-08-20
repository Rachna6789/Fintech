import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crash_reporting_service.dart';

final errorLoggingServiceProvider = Provider<ErrorLoggingService>((ref) {
  return ErrorLoggingService(ref.watch(crashReportingServiceProvider));
});

class ErrorLoggingService {
  ErrorLoggingService(this._crashReporting);

  final CrashReportingService _crashReporting;

  Future<void> logError(Object error, StackTrace stack, {String? reason}) async {
    // Console first
    // ignore: avoid_print
    print('Error: $error\n$stack');
    await _crashReporting.recordError(error, stack, reason: reason);
  }
}
