import '../../../../core/errors/result.dart';
import '../repositories/price_alert_repository.dart';

class SetPriceAlertEnabledUseCase {
  const SetPriceAlertEnabledUseCase(this._repository);

  final PriceAlertRepository _repository;

  Future<Result<void>> call(String id, bool enabled) {
    return _repository.setAlertEnabled(id, enabled);
  }
}
