import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../entities/profile_setup_data.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> watchAuthState();

  Future<Result<AuthUser?>> getCurrentUser();

  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<AuthUser>> signInWithGoogle();

  Future<Result<void>> sendEmailVerification();

  Future<Result<AuthUser?>> reloadCurrentUser();

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<AuthUser>> completeProfileSetup(ProfileSetupData data);

  Future<Result<bool>> authenticateWithBiometrics();

  Future<Result<bool>> isBiometricEnabled();

  Future<Result<void>> setBiometricEnabled(bool enabled);

  Future<Result<void>> signOut();
}
