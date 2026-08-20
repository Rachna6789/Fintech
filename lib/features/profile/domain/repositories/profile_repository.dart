import '../../../../core/errors/result.dart';
import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Stream<Profile?> watchProfile();

  Future<Result<Profile?>> getProfile();

  Future<Result<Profile>> updateProfile({
    String? displayName,
    String? baseCurrency,
    String? photoUrl,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  });

  Future<Result<String>> uploadProfilePicture(String path, dynamic file);

  Future<Result<void>> deleteAccount();
}
