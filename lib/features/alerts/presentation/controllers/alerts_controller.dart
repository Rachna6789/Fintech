import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../market/domain/entities/market_quote.dart';
import '../../../market/presentation/providers/market_providers.dart';
import '../../../market/presentation/state/market_state.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/entities/price_alert_condition.dart';
import '../../domain/entities/price_alert_input.dart';
import '../providers/alerts_providers.dart';
import '../state/alerts_state.dart';

class AlertsController extends Notifier<AlertsState> {
  StreamSubscription<List<PriceAlert>>? _subscription;

  @override
  AlertsState build() {
    ref.onDispose(() => _subscription?.cancel());
    ref.listen<MarketState>(
      marketControllerProvider,
      (previous, next) {
        _handleMarketQuotes(next.quotes);
      },
    );
    _watchAlerts();
    return const AlertsState.initial();
  }

  Future<bool> createAlert({
    required String symbol,
    required String assetName,
    required double targetPrice,
    required PriceAlertCondition condition,
    bool isEnabled = true,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    final result = await ref.read(createPriceAlertUseCaseProvider)(
      PriceAlertInput(
        symbol: symbol,
        assetName: assetName,
        targetPrice: targetPrice,
        condition: condition,
        isEnabled: isEnabled,
      ),
    );

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isSubmitting: false, successMessage: 'Alert created.');
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> deleteAlert(String id) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    final result = await ref.read(deletePriceAlertUseCaseProvider)(id);
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isSubmitting: false, successMessage: 'Alert deleted.');
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> toggleAlert(String id, bool enabled) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    final result = await ref.read(setPriceAlertEnabledUseCaseProvider)(id, enabled);
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: enabled ? 'Alert enabled.' : 'Alert disabled.',
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> triggerAlert(String id, double currentPrice) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    final result = await ref.read(triggerPriceAlertUseCaseProvider)(id, currentPrice);
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isSubmitting: false, successMessage: 'Alert triggered.');
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  void _watchAlerts() {
    _subscription?.cancel();
    _subscription = ref.read(watchPriceAlertsUseCaseProvider)().listen(
      (alerts) {
        state = state.copyWith(alerts: alerts, isLoading: false, clearError: true);
        _handleMarketQuotes(ref.read(marketControllerProvider).quotes);
      },
      onError: (Object error) {
        state = state.copyWith(isLoading: false, errorMessage: error.toString());
      },
    );
  }

  Future<void> _handleMarketQuotes(List<MarketQuote> quotes) async {
    for (final alert in state.alerts) {
      if (!alert.isEnabled || alert.hasTriggered) continue;
      final quote = quotes.where((item) => item.symbol == alert.symbol.toUpperCase()).firstOrNull;
      if (quote == null) continue;
      await triggerAlert(alert.id, quote.price);
    }
  }
}
