import '../../domain/entities/price_alert.dart';

class AlertsState {
  const AlertsState({
    required this.alerts,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  const AlertsState.initial()
      : alerts = const [],
        isLoading = true,
        isSubmitting = false,
        errorMessage = null,
        successMessage = null;

  final List<PriceAlert> alerts;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  AlertsState copyWith({
    List<PriceAlert>? alerts,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AlertsState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }
}
