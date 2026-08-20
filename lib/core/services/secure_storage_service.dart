import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }

  Future<void> saveAuthToken(String token) {
    return write(StorageKeys.authToken, token);
  }

  Future<void> saveRefreshToken(String token) {
    return write(StorageKeys.refreshToken, token);
  }

  Future<String?> readAuthToken() {
    return read(StorageKeys.authToken);
  }

  Future<String?> readRefreshToken() {
    return read(StorageKeys.refreshToken);
  }

  Future<void> deleteAuthToken() {
    return delete(StorageKeys.authToken);
  }

  Future<void> saveUserId(String userId) {
    return write(StorageKeys.userId, userId);
  }

  Future<String?> readUserId() {
    return read(StorageKeys.userId);
  }

  Future<void> clearAuthSession() async {
    await Future.wait([
      delete(StorageKeys.authToken),
      delete(StorageKeys.refreshToken),
      delete(StorageKeys.userId),
    ]);
  }
}
