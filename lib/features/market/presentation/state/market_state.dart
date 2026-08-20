import '../../domain/entities/market_connection_status.dart';
import '../../domain/entities/market_quote.dart';

class MarketState {
  const MarketState({
    required this.symbols,
    required this.quotes,
    required this.connectionStatus,
    required this.recentSearches,
    this.isOffline = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  const MarketState.initial()
      : symbols = const ['AAPL', 'MSFT', 'GOOGL', 'BTC-USD', 'ETH-USD'],
        quotes = const [],
        recentSearches = const [],
        connectionStatus = MarketConnectionStatus.disconnected,
        isOffline = false,
        isLoading = true,
        isRefreshing = false,
        errorMessage = null;

  final List<String> symbols;
  final List<MarketQuote> quotes;
  final List<String> recentSearches;
  final MarketConnectionStatus connectionStatus;
  final bool isOffline;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  MarketState copyWith({
    List<String>? symbols,
    List<MarketQuote>? quotes,
    List<String>? recentSearches,
    MarketConnectionStatus? connectionStatus,
    bool? isOffline,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MarketState(
      symbols: symbols ?? this.symbols,
      quotes: quotes ?? this.quotes,
      recentSearches: recentSearches ?? this.recentSearches,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isOffline: isOffline ?? this.isOffline,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
