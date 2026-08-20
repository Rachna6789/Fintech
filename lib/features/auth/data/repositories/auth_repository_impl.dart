import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/profile_setup_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Stream<AuthUser?> watchAuthState() => _remoteDataSource.watchAuthState();

  @override
  Future<Result<AuthUser?>> getCurrentUser() {
    return _guard(_remoteDataSource.getCurrentUser);
  }

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _remoteDataSource.signInWithEmail(email: email, password: password),
    );
  }

  @override
  Future<Result<AuthUser>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _guard(
      () => _remoteDataSource.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() {
    return _guard(_remoteDataSource.signInWithGoogle);
  }

  @override
  Future<Result<void>> sendEmailVerification() {
    return _guard(_remoteDataSource.sendEmailVerification);
  }

  @override
  Future<Result<AuthUser?>> reloadCurrentUser() {
    return _guard(_remoteDataSource.reloadCurrentUser);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) {
    return _guard(() => _remoteDataSource.sendPasswordResetEmail(email));
  }

  @override
  Future<Result<AuthUser>> completeProfileSetup(ProfileSetupData data) {
    return _guard(() => _remoteDataSource.completeProfileSetup(data));
  }

  @override
  Future<Result<bool>> authenticateWithBiometrics() {
    return _guard(() async {
      final enabled = await _localDataSource.isBiometricEnabled();
      final hasUser = await _localDataSource.hasPersistedUser();
      if (!enabled || !hasUser) return false;
      return _localDataSource.authenticateWithBiometrics();
    });
  }

  @override
  Future<Result<bool>> isBiometricEnabled() {
    return _guard(_localDataSource.isBiometricEnabled);
  }

  @override
  Future<Result<void>> setBiometricEnabled(bool enabled) {
    return _guard(() => _localDataSource.setBiometricEnabled(enabled));
  }

  @override
  Future<Result<void>> signOut() {
    return _guard(_remoteDataSource.signOut);
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      final Failure failure = ErrorMapper.toFailure(error);
      return FailureResult<T>(failure);
    }
  }
}
