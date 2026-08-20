import '../../../../core/errors/result.dart';
import '../repositories/market_repository.dart';

class SubscribeMarketSymbolsUseCase {
  const SubscribeMarketSymbolsUseCase(this._repository);

  final MarketRepository _repository;

  Future<Result<void>> call(List<String> symbols) {
    return _repository.subscribe(symbols);
  }
}
