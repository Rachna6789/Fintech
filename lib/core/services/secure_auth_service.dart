import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_auth_service.dart';
import 'notification_service.dart';
import 'secure_storage_service.dart';

final secureAuthServiceProvider = Provider<SecureAuthService>((ref) {
  return SecureAuthService(
    authService: ref.watch(firebaseAuthServiceProvider),
    notificationService: ref.watch(notificationServiceProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
});

class SecureAuthService {
  const SecureAuthService({
    required FirebaseAuthService authService,
    required NotificationService notificationService,
    required SecureStorageService secureStorageService,
  })  : _authService = authService,
        _notificationService = notificationService,
        _secureStorageService = secureStorageService;

  final FirebaseAuthService _authService;
  final NotificationService _notificationService;
  final SecureStorageService _secureStorageService;

  Future<bool> get hasValidSession async {
    final user = _authService.currentUser;
    if (user == null) return false;

    await user.reload();
    final token = await _authService.getIdToken(forceRefresh: true);
    return token.isNotEmpty;
  }

  Future<void> refreshSecurityContext() async {
    await _authService.getIdToken(forceRefresh: true);
    await _notificationService.syncTokenLocally();
  }

  Future<void> revokeLocalSession() async {
    await _secureStorageService.clearAuthSession();
  }
}
