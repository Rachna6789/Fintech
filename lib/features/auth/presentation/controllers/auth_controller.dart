import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/profile_setup_data.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  StreamSubscription<AuthUser?>? _authSubscription;

  @override
  AuthState build() {
    ref.onDispose(() => _authSubscription?.cancel());
    _watchAuthState();
    _loadBiometricPreference();
    return const AuthState.initial();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _runAuthAction(
      () => ref.read(signInUseCaseProvider)(email: email, password: password),
    );
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _runAuthAction(
      () => ref.read(registerUseCaseProvider)(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    await _runAuthAction(() => ref.read(signInWithGoogleUseCaseProvider)());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    final result = await ref.read(forgotPasswordUseCaseProvider)(email);
    state = result.fold(
      onSuccess: (_) => state.copyWith(
        isLoading: false,
        successMessage: 'Password reset email sent.',
      ),
      onFailure: (failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> resendEmailVerification() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    final result = await ref.read(sendEmailVerificationUseCaseProvider)();
    state = result.fold(
      onSuccess: (_) => state.copyWith(
        isLoading: false,
        successMessage: 'Verification email sent.',
      ),
      onFailure: (failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> refreshEmailVerification() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(reloadAuthUserUseCaseProvider)();
    state = result.fold(
      onSuccess: (user) => state.copyWith(
        isLoading: false,
        user: user,
        status: AuthState.resolveStatus(user),
        clearUser: user == null,
      ),
      onFailure: (failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> completeProfileSetup({
    required String displayName,
    required String baseCurrency,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    final result = await ref.read(completeProfileSetupUseCaseProvider)(
      ProfileSetupData(displayName: displayName, baseCurrency: baseCurrency),
    );
    state = result.fold(
      onSuccess: (user) => state.copyWith(
        isLoading: false,
        user: user,
        status: AuthState.resolveStatus(user),
      ),
      onFailure: (failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> authenticateWithBiometrics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(authenticateWithBiometricsUseCaseProvider)();
    state = result.fold(
      onSuccess: (authenticated) => state.copyWith(
        isLoading: false,
        successMessage: authenticated ? 'Biometric login successful.' : null,
        errorMessage: authenticated ? null : 'Biometric login is not enabled.',
      ),
      onFailure: (failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final result = await ref.read(setBiometricEnabledUseCaseProvider)(enabled);
    state = result.fold(
      onSuccess: (_) => state.copyWith(isBiometricEnabled: enabled),
      onFailure: (failure) => state.copyWith(errorMessage: failure.message),
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(signOutUseCaseProvider)();
    state = result.fold(
      onSuccess: (_) => state.copyWith(
        isLoading: false,
        status: AuthFlowStatus.unauthenticated,
        clearUser: true,
      ),
      onFailure: (failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> _runAuthAction(
      Future<Result<AuthUser>> Function() action) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    final result = await action();
    state = result.fold(
      onSuccess: (user) => state.copyWith(
        isLoading: false,
        user: user,
        status: AuthState.resolveStatus(user),
      ),
      onFailure: (failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
    );
  }

  void _watchAuthState() {
    _authSubscription?.cancel();
    _authSubscription =
        ref.read(authRepositoryProvider).watchAuthState().listen(
      (user) {
        state = state.copyWith(
          user: user,
          clearUser: user == null,
          status: AuthState.resolveStatus(user),
        );
      },
      onError: (Object error) {
        state = state.copyWith(
          status: AuthFlowStatus.unauthenticated,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> _loadBiometricPreference() async {
    final result = await ref.read(isBiometricEnabledUseCaseProvider)();
    state = result.fold(
      onSuccess: (enabled) => state.copyWith(isBiometricEnabled: enabled),
      onFailure: (_) => state,
    );
  }
}
