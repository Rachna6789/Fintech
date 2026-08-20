import '../../../../core/errors/result.dart';
import '../entities/market_quote.dart';
import '../repositories/market_repository.dart';

class FetchMarketQuotesUseCase {
  const FetchMarketQuotesUseCase(this._repository);

  final MarketRepository _repository;

  Future<Result<List<MarketQuote>>> call(List<String> symbols) {
    return _repository.fetchQuotes(symbols);
  }
}
