import '../../../../core/errors/result.dart';
import '../repositories/price_alert_repository.dart';

class DeletePriceAlertUseCase {
  const DeletePriceAlertUseCase(this._repository);

  final PriceAlertRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteAlert(id);
}
