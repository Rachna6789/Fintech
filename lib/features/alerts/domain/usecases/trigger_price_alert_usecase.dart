import '../../../../core/errors/result.dart';
import '../repositories/price_alert_repository.dart';

class TriggerPriceAlertUseCase {
  const TriggerPriceAlertUseCase(this._repository);

  final PriceAlertRepository _repository;

  Future<Result<void>> call(String id, double currentPrice) {
    return _repository.triggerAlert(id, currentPrice);
  }
}
