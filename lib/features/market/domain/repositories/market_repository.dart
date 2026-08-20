import '../../../../core/errors/result.dart';
import '../entities/historical_price.dart';
import '../entities/market_connection_status.dart';
import '../entities/market_quote.dart';

abstract interface class MarketRepository {
  Stream<MarketConnectionStatus> watchConnectionStatus();

  Stream<MarketQuote> watchLiveQuotes();

  Future<Result<List<MarketQuote>>> fetchQuotes(List<String> symbols);

  Future<Result<List<MarketQuote>>> readCachedQuotes();

  Future<Result<List<HistoricalPrice>>> fetchHistory(String symbol);

  Future<Result<void>> connect();

  Future<Result<void>> reconnect();

  Future<Result<void>> disconnect();

  Future<Result<void>> subscribe(List<String> symbols);

  Future<Result<void>> unsubscribe(List<String> symbols);
}
