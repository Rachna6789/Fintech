import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/offline/offline_action.dart';
import '../../../../core/offline/offline_sync_service.dart';
import '../../../../core/settings/data/settings_local_data_source.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource dataSource,
    required SettingsLocalDataSource settingsLocalDataSource,
    required NetworkInfo networkInfo,
    required OfflineSyncService offlineSyncService,
  })  : _dataSource = dataSource,
        _settingsLocal = settingsLocalDataSource,
        _networkInfo = networkInfo,
        _offlineSyncService = offlineSyncService;

  final ProfileRemoteDataSource _dataSource;
  final SettingsLocalDataSource _settingsLocal;
  final NetworkInfo _networkInfo;
  final OfflineSyncService _offlineSyncService;

  @override
  Stream<Profile?> watchProfile() => _dataSource.watchProfile();

  @override
  Future<Result<Profile?>> getProfile() async {
    try {
      if (await _networkInfo.isConnected) {
        final profile = await _dataSource.getProfile();
        if (profile != null) {
          await _settingsLocal.patchSettings(
            baseCurrency: profile.baseCurrency,
            isDarkMode: profile.isDarkMode,
            notificationsEnabled: profile.notificationsEnabled,
            biometricEnabled: profile.biometricEnabled,
          );
        }
        return Success(profile);
      }

      final settings = await _settingsLocal.readSettings();
      final remote = await _dataSource.getProfile();
      if (remote == null) return const Success(null);
      return Success(
        remote.copyWith(
          baseCurrency: settings.baseCurrency,
          isDarkMode: settings.isDarkMode,
          notificationsEnabled: settings.notificationsEnabled,
          biometricEnabled: settings.biometricEnabled,
        ),
      );
    } on AppException catch (error) {
      final settings = await _settingsLocal.readSettings();
      try {
        final remote = await _dataSource.getProfile();
        if (remote == null) return const Success(null);
        return Success(
          remote.copyWith(
            baseCurrency: settings.baseCurrency,
            isDarkMode: settings.isDarkMode,
            notificationsEnabled: settings.notificationsEnabled,
            biometricEnabled: settings.biometricEnabled,
          ),
        );
      } catch (_) {
        return FailureResult(ErrorMapper.toFailure(error));
      }
    }
  }

  @override
  Future<Result<Profile>> updateProfile({
    String? displayName,
    String? baseCurrency,
    String? photoUrl,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) async {
    await _settingsLocal.patchSettings(
      baseCurrency: baseCurrency,
      isDarkMode: isDarkMode,
      notificationsEnabled: notificationsEnabled,
      biometricEnabled: biometricEnabled,
    );

    if (await _networkInfo.isConnected) {
      try {
        final profile = await _dataSource.updateProfile(
          displayName: displayName,
          baseCurrency: baseCurrency,
          photoUrl: photoUrl,
          isDarkMode: isDarkMode,
          notificationsEnabled: notificationsEnabled,
          biometricEnabled: biometricEnabled,
        );
        return Success(profile);
      } on AppException catch (error) {
        await _enqueueSettingsPatch(
          baseCurrency: baseCurrency,
          isDarkMode: isDarkMode,
          notificationsEnabled: notificationsEnabled,
          biometricEnabled: biometricEnabled,
          displayName: displayName,
          photoUrl: photoUrl,
        );
        final cached = await _buildCachedProfile(
          displayName: displayName,
          photoUrl: photoUrl,
        );
        if (cached == null) {
          return FailureResult(ErrorMapper.toFailure(error));
        }
        return Success(cached);
      }
    }

    await _enqueueSettingsPatch(
      baseCurrency: baseCurrency,
      isDarkMode: isDarkMode,
      notificationsEnabled: notificationsEnabled,
      biometricEnabled: biometricEnabled,
      displayName: displayName,
      photoUrl: photoUrl,
    );

    final cached = await _buildCachedProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
    if (cached == null) {
      return const FailureResult(
        NetworkFailure(message: 'Profile unavailable offline.'),
      );
    }
    return Success(cached);
  }

  @override
  Future<Result<String>> uploadProfilePicture(String path, dynamic file) async {
    try {
      final url = await _dataSource.uploadProfilePicture(path, file);
      return Success(url);
    } on AppException catch (error) {
      return FailureResult(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _dataSource.deleteAccount();
      return const Success(null);
    } on AppException catch (error) {
      return FailureResult(ErrorMapper.toFailure(error));
    }
  }

  Future<void> _enqueueSettingsPatch({
    String? displayName,
    String? baseCurrency,
    String? photoUrl,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) {
    return _offlineSyncService.enqueue(
      action: OfflineActions.patch,
      entity: OfflineEntities.settings,
      payload: {
        if (displayName != null) 'displayName': displayName,
        if (baseCurrency != null) 'baseCurrency': baseCurrency,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (isDarkMode != null) 'isDarkMode': isDarkMode,
        if (notificationsEnabled != null)
          'notificationsEnabled': notificationsEnabled,
        if (biometricEnabled != null) 'biometricEnabled': biometricEnabled,
      },
    );
  }

  Future<Profile?> _buildCachedProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final remote = await _dataSource.getProfile();
    if (remote == null) return null;
    final settings = await _settingsLocal.readSettings();
    return remote.copyWith(
      displayName: displayName ?? remote.displayName,
      photoUrl: photoUrl ?? remote.photoUrl,
      baseCurrency: settings.baseCurrency,
      isDarkMode: settings.isDarkMode,
      notificationsEnabled: settings.notificationsEnabled,
      biometricEnabled: settings.biometricEnabled,
    );
  }
}

// AppExceptionFailure was removed because `Failure` is a sealed class in the
// `failure.dart` library. We map AppException -> Failure using `ErrorMapper`.
