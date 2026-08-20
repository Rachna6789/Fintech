import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/offline/offline_providers.dart';
import '../../../../core/settings/providers/settings_providers.dart';
import '../../domain/entities/market_quote.dart';
import '../providers/market_providers.dart';
import '../state/market_state.dart';

class MarketController extends Notifier<MarketState> {
  StreamSubscription<dynamic>? _connectionSubscription;
  StreamSubscription<MarketQuote>? _quoteSubscription;

  @override
  MarketState build() {
    ref.onDispose(() {
      _connectionSubscription?.cancel();
      _quoteSubscription?.cancel();
    });
    _watchConnection();
    _watchQuotes();
    _watchOfflineStatus();
    _bootstrap();
    return const MarketState.initial();
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    final result =
        await ref.read(fetchMarketQuotesUseCaseProvider)(state.symbols);
    state = result.fold(
      onSuccess: (quotes) => state.copyWith(
        quotes: quotes,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
      ),
      onFailure: (failure) {
        if (state.quotes.isNotEmpty) {
          return state.copyWith(
            isLoading: false,
            isRefreshing: false,
            isOffline: true,
            errorMessage: failure.message,
          );
        }
        return state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> reconnect() async {
    final result = await ref.read(reconnectMarketSocketUseCaseProvider)();
    state = result.fold(
      onSuccess: (_) => state.copyWith(clearError: true),
      onFailure: (failure) => state.copyWith(errorMessage: failure.message),
    );
  }

  Future<void> updateSymbols(List<String> symbols) async {
    final normalized = symbols
        .map((symbol) => symbol.trim().toUpperCase())
        .where((symbol) => symbol.isNotEmpty)
        .toSet()
        .toList();
    if (normalized.isEmpty) return;

    final searchStore = ref.read(marketSearchLocalDataSourceProvider);
    for (final symbol in normalized) {
      await searchStore.addSearch(symbol);
    }
    final recentSearches = await searchStore.readRecentSearches();

    state = state.copyWith(
      symbols: normalized,
      recentSearches: recentSearches,
      isLoading: true,
    );

    await ref.read(appSettingsProvider.notifier).patch(marketSymbols: normalized);
    await refresh();
    await _subscribe();
  }

  Future<void> _bootstrap() async {
    final settings = await ref.read(settingsLocalDataSourceProvider).readSettings();
    final searchStore = ref.read(marketSearchLocalDataSourceProvider);
    final recentSearches = await searchStore.readRecentSearches();
    final symbols = settings.marketSymbols;

    state = state.copyWith(
      symbols: symbols,
      recentSearches: recentSearches,
    );

    final cached = await ref.read(marketRepositoryProvider).readCachedQuotes();
    state = cached.fold(
      onSuccess: (quotes) => state.copyWith(
        quotes: quotes,
        isLoading: quotes.isEmpty,
      ),
      onFailure: (_) => state,
    );

    final offline = ref.read(offlineStatusProvider);
    state = state.copyWith(isOffline: !offline.isOnline);

    await refresh();
    if (offline.isOnline) {
      await ref.read(connectMarketSocketUseCaseProvider)();
      await _subscribe();
    }
  }

  Future<void> _subscribe() async {
    final result = await ref.read(subscribeMarketSymbolsUseCaseProvider)(
      state.symbols,
    );
    state = result.fold(
      onSuccess: (_) => state.copyWith(clearError: true),
      onFailure: (failure) => state.copyWith(errorMessage: failure.message),
    );
  }

  void _watchConnection() {
    _connectionSubscription?.cancel();
    _connectionSubscription =
        ref.read(watchMarketConnectionUseCaseProvider)().listen((status) {
      state = state.copyWith(connectionStatus: status);
    });
  }

  void _watchQuotes() {
    _quoteSubscription?.cancel();
    _quoteSubscription =
        ref.read(watchLiveMarketQuotesUseCaseProvider)().listen((quote) {
      final quotes = [...state.quotes];
      final index = quotes.indexWhere((item) => item.symbol == quote.symbol);
      if (index == -1) {
        quotes.add(quote);
      } else {
        quotes[index] = quote;
      }
      state = state.copyWith(quotes: quotes, isLoading: false);
    });
  }

  void _watchOfflineStatus() {
    ref.listen(offlineStatusProvider, (previous, next) {
      state = state.copyWith(isOffline: !next.isOnline);
      if (next.isOnline && previous?.isOnline == false) {
        unawaited(refresh());
        unawaited(ref.read(connectMarketSocketUseCaseProvider)());
        unawaited(_subscribe());
      }
    });
  }
}
