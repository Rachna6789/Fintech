import '../entities/market_connection_status.dart';
import '../repositories/market_repository.dart';

class WatchMarketConnectionUseCase {
  const WatchMarketConnectionUseCase(this._repository);

  final MarketRepository _repository;

  Stream<MarketConnectionStatus> call() => _repository.watchConnectionStatus();
}
