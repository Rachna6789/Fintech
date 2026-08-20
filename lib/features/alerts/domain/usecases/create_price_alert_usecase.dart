import '../../../../core/errors/result.dart';
import '../entities/price_alert_input.dart';
import '../repositories/price_alert_repository.dart';

class CreatePriceAlertUseCase {
  const CreatePriceAlertUseCase(this._repository);

  final PriceAlertRepository _repository;

  Future<Result<void>> call(PriceAlertInput input) {
    return _repository.createAlert(input);
  }
}
