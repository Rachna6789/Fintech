import '../../../../core/errors/result.dart';
import '../repositories/market_repository.dart';

class ReconnectMarketSocketUseCase {
  const ReconnectMarketSocketUseCase(this._repository);

  final MarketRepository _repository;

  Future<Result<void>> call() => _repository.reconnect();
}
