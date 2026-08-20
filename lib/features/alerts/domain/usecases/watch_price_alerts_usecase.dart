import '../entities/price_alert.dart';
import '../repositories/price_alert_repository.dart';

class WatchPriceAlertsUseCase {
  const WatchPriceAlertsUseCase(this._repository);

  final PriceAlertRepository _repository;

  Stream<List<PriceAlert>> call() => _repository.watchAlerts();
}
