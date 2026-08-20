import '../../../../core/errors/result.dart';
import '../entities/historical_price.dart';
import '../repositories/market_repository.dart';

class FetchMarketHistoryUseCase {
  const FetchMarketHistoryUseCase(this._repository);

  final MarketRepository _repository;

  Future<Result<List<HistoricalPrice>>> call(String symbol) {
    return _repository.fetchHistory(symbol);
  }
}
