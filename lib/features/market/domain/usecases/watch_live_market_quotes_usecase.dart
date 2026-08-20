import '../entities/market_quote.dart';
import '../repositories/market_repository.dart';

class WatchLiveMarketQuotesUseCase {
  const WatchLiveMarketQuotesUseCase(this._repository);

  final MarketRepository _repository;

  Stream<MarketQuote> call() => _repository.watchLiveQuotes();
}
