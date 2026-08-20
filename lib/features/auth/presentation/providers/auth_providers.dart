import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/authenticate_with_biometrics_usecase.dart';
import '../../domain/usecases/complete_profile_setup_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_auth_user_usecase.dart';
import '../../domain/usecases/is_biometric_enabled_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reload_auth_user_usecase.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
import '../../domain/usecases/set_biometric_enabled_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../controllers/auth_controller.dart';
import '../state/auth_state.dart';

final localAuthenticationProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(
    secureStorageService: ref.watch(secureStorageServiceProvider),
    localAuthentication: ref.watch(localAuthenticationProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final getCurrentAuthUserUseCaseProvider =
    Provider<GetCurrentAuthUserUseCase>((ref) {
  return GetCurrentAuthUserUseCase(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  return ForgotPasswordUseCase(ref.watch(authRepositoryProvider));
});

final sendEmailVerificationUseCaseProvider =
    Provider<SendEmailVerificationUseCase>((ref) {
  return SendEmailVerificationUseCase(ref.watch(authRepositoryProvider));
});

final reloadAuthUserUseCaseProvider = Provider<ReloadAuthUserUseCase>((ref) {
  return ReloadAuthUserUseCase(ref.watch(authRepositoryProvider));
});

final completeProfileSetupUseCaseProvider =
    Provider<CompleteProfileSetupUseCase>((ref) {
  return CompleteProfileSetupUseCase(ref.watch(authRepositoryProvider));
});

final authenticateWithBiometricsUseCaseProvider =
    Provider<AuthenticateWithBiometricsUseCase>((ref) {
  return AuthenticateWithBiometricsUseCase(ref.watch(authRepositoryProvider));
});

final setBiometricEnabledUseCaseProvider =
    Provider<SetBiometricEnabledUseCase>((ref) {
  return SetBiometricEnabledUseCase(ref.watch(authRepositoryProvider));
});

final isBiometricEnabledUseCaseProvider =
    Provider<IsBiometricEnabledUseCase>((ref) {
  return IsBiometricEnabledUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
