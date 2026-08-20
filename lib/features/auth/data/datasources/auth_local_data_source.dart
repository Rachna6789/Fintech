import 'package:local_auth/local_auth.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/secure_storage_service.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource({
    required SecureStorageService secureStorageService,
    required LocalAuthentication localAuthentication,
  })  : _secureStorageService = secureStorageService,
        _localAuthentication = localAuthentication;

  static const _biometricEnabledKey = 'biometric_enabled';

  final SecureStorageService _secureStorageService;
  final LocalAuthentication _localAuthentication;

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorageService.read(_biometricEnabledKey);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) {
    return _secureStorageService.write(
        _biometricEnabledKey, enabled.toString());
  }

  Future<bool> authenticateWithBiometrics() async {
    final canCheck = await _localAuthentication.canCheckBiometrics;
    final isSupported = await _localAuthentication.isDeviceSupported();
    if (!canCheck || !isSupported) {
      throw const AuthException('Biometric authentication is not available.');
    }

    return _localAuthentication.authenticate(
      localizedReason: 'Unlock FinTrack securely',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
        sensitiveTransaction: true,
      ),
    );
  }

  Future<bool> hasPersistedUser() async {
    final userId = await _secureStorageService.read(StorageKeys.userId);
    return userId != null && userId.isNotEmpty;
  }
}
