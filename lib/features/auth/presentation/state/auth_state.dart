import '../../domain/entities/auth_user.dart';

enum AuthFlowStatus {
  checking,
  unauthenticated,
  authenticated,
  emailUnverified,
  profileIncomplete,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isBiometricEnabled = false,
  });

  const AuthState.initial()
      : status = AuthFlowStatus.checking,
        user = null,
        isLoading = false,
        errorMessage = null,
        successMessage = null,
        isBiometricEnabled = false;

  final AuthFlowStatus status;
  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isBiometricEnabled;

  AuthState copyWith({
    AuthFlowStatus? status,
    AuthUser? user,
    bool? clearUser,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    bool? isBiometricEnabled,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser == true ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }

  static AuthFlowStatus resolveStatus(AuthUser? user) {
    if (user == null) return AuthFlowStatus.unauthenticated;
    if (!user.isEmailVerified) return AuthFlowStatus.emailUnverified;
    if (!user.isProfileComplete) return AuthFlowStatus.profileIncomplete;
    return AuthFlowStatus.authenticated;
  }
}
