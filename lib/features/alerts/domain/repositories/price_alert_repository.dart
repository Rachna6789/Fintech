import '../../../../core/errors/result.dart';
import '../entities/price_alert.dart';
import '../entities/price_alert_input.dart';

abstract interface class PriceAlertRepository {
  Stream<List<PriceAlert>> watchAlerts();

  Future<Result<void>> createAlert(PriceAlertInput input);

  Future<Result<void>> deleteAlert(String id);

  Future<Result<void>> setAlertEnabled(String id, bool enabled);

  Future<Result<void>> triggerAlert(String id, double currentPrice);
}
