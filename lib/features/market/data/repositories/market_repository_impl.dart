import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/historical_price.dart';
import '../../domain/entities/market_connection_status.dart';
import '../../domain/entities/market_quote.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_local_data_source.dart';
import '../datasources/market_remote_data_source.dart';
import '../services/market_socket_service.dart';

class MarketRepositoryImpl implements MarketRepository {
  const MarketRepositoryImpl({
    required MarketRemoteDataSource remoteDataSource,
    required MarketLocalDataSource localDataSource,
    required MarketSocketService socketService,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _socketService = socketService,
        _networkInfo = networkInfo;

  final MarketRemoteDataSource _remoteDataSource;
  final MarketLocalDataSource _localDataSource;
  final MarketSocketService _socketService;
  final NetworkInfo _networkInfo;

  @override
  Stream<MarketConnectionStatus> watchConnectionStatus() {
    return _socketService.statusStream;
  }

  @override
  Stream<MarketQuote> watchLiveQuotes() {
    return _socketService.quoteStream.asyncMap((quote) async {
      await _mergeQuoteIntoCache(quote);
      return quote;
    });
  }

  @override
  Future<Result<List<MarketQuote>>> fetchQuotes(List<String> symbols) async {
    if (await _networkInfo.isConnected) {
      return _guard(() async {
        final quotes = await _remoteDataSource.fetchQuotes(symbols);
        await _localDataSource.saveQuotes(quotes);
        return quotes;
      });
    }

    final cached = await _localDataSource.readQuotes();
    if (cached.isEmpty) {
      return const FailureResult(
        NetworkFailure(message: 'No cached market data available offline.'),
      );
    }
    return Success(cached);
  }

  @override
  Future<Result<List<MarketQuote>>> readCachedQuotes() {
    return _guard(_localDataSource.readQuotes);
  }

  @override
  Future<Result<List<HistoricalPrice>>> fetchHistory(String symbol) async {
    if (await _networkInfo.isConnected) {
      return _guard(() async {
        final history = await _remoteDataSource.fetchHistory(symbol);
        await _localDataSource.saveHistory(symbol, history);
        return history;
      });
    }

    final cached = await _localDataSource.readHistory(symbol);
    if (cached.isEmpty) {
      return const FailureResult(
        NetworkFailure(message: 'No cached history available offline.'),
      );
    }
    return Success(cached);
  }

  @override
  Future<Result<void>> connect() {
    return _guard(_socketService.connect);
  }

  @override
  Future<Result<void>> reconnect() {
    return _guard(_socketService.reconnect);
  }

  @override
  Future<Result<void>> disconnect() {
    return _guard(_socketService.disconnect);
  }

  @override
  Future<Result<void>> subscribe(List<String> symbols) {
    return _guard(() => _socketService.subscribe(symbols));
  }

  @override
  Future<Result<void>> unsubscribe(List<String> symbols) {
    return _guard(() => _socketService.unsubscribe(symbols));
  }

  Future<void> _mergeQuoteIntoCache(MarketQuote quote) async {
    final cached = await _localDataSource.readQuotes();
    final quotes = [...cached];
    final index = quotes.indexWhere((item) => item.symbol == quote.symbol);
    if (index == -1) {
      quotes.add(quote);
    } else {
      quotes[index] = quote;
    }
    await _localDataSource.saveQuotes(quotes);
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      final Failure failure = ErrorMapper.toFailure(error);
      return FailureResult<T>(failure);
    }
  }
}
