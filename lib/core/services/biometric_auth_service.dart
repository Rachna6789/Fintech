import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'secure_storage_service.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(ref.watch(secureStorageServiceProvider));
});

class BiometricAuthService {
  BiometricAuthService(this._secureStorageService) : _localAuth = LocalAuthentication();

  final SecureStorageService _secureStorageService;
  final LocalAuthentication _localAuth;

  static const _biometricEnabledKey = 'biometric_enabled';

  Future<bool> canCheckBiometrics() => _localAuth.canCheckBiometrics;

  Future<bool> isDeviceSupported() => _localAuth.isDeviceSupported();

  Future<List<BiometricType>> getAvailableBiometrics() => _localAuth.getAvailableBiometrics();

  Future<bool> authenticate({String reason = 'Authenticate'}) async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: false),
      );
      return didAuthenticate;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    final v = await _secureStorageService.read(_biometricEnabledKey);
    return v == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      await _secureStorageService.write(_biometricEnabledKey, 'true');
    } else {
      await _secureStorageService.delete(_biometricEnabledKey);
    }
  }
}
