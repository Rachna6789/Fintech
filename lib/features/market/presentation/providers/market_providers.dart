import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config_provider.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/offline/offline_providers.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/settings/providers/settings_providers.dart';
import '../../data/datasources/market_local_data_source.dart';
import '../../data/datasources/market_remote_data_source.dart';
import '../../data/repositories/market_repository_impl.dart';
import '../../data/services/market_socket_service.dart';
import '../../domain/repositories/market_repository.dart';
import '../../domain/usecases/connect_market_socket_usecase.dart';
import '../../domain/usecases/fetch_market_history_usecase.dart';
import '../../domain/usecases/fetch_market_quotes_usecase.dart';
import '../../domain/usecases/reconnect_market_socket_usecase.dart';
import '../../domain/usecases/subscribe_market_symbols_usecase.dart';
import '../../domain/usecases/watch_live_market_quotes_usecase.dart';
import '../../domain/usecases/watch_market_connection_usecase.dart';
import '../controllers/market_controller.dart';
import '../state/market_state.dart';

final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>((ref) {
  return MarketRemoteDataSource(ref.watch(dioProvider));
});

final marketLocalDataSourceProvider = Provider<MarketLocalDataSource>((ref) {
  return MarketLocalDataSource(ref.watch(hiveServiceProvider));
});

final marketSocketServiceProvider = Provider<MarketSocketService>((ref) {
  final service = MarketSocketService(
    config: ref.watch(envConfigProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepositoryImpl(
    remoteDataSource: ref.watch(marketRemoteDataSourceProvider),
    localDataSource: ref.watch(marketLocalDataSourceProvider),
    socketService: ref.watch(marketSocketServiceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final fetchMarketQuotesUseCaseProvider =
    Provider<FetchMarketQuotesUseCase>((ref) {
  return FetchMarketQuotesUseCase(ref.watch(marketRepositoryProvider));
});

final fetchMarketHistoryUseCaseProvider =
    Provider<FetchMarketHistoryUseCase>((ref) {
  return FetchMarketHistoryUseCase(ref.watch(marketRepositoryProvider));
});

final watchLiveMarketQuotesUseCaseProvider =
    Provider<WatchLiveMarketQuotesUseCase>((ref) {
  return WatchLiveMarketQuotesUseCase(ref.watch(marketRepositoryProvider));
});

final watchMarketConnectionUseCaseProvider =
    Provider<WatchMarketConnectionUseCase>((ref) {
  return WatchMarketConnectionUseCase(ref.watch(marketRepositoryProvider));
});

final connectMarketSocketUseCaseProvider =
    Provider<ConnectMarketSocketUseCase>((ref) {
  return ConnectMarketSocketUseCase(ref.watch(marketRepositoryProvider));
});

final reconnectMarketSocketUseCaseProvider =
    Provider<ReconnectMarketSocketUseCase>((ref) {
  return ReconnectMarketSocketUseCase(ref.watch(marketRepositoryProvider));
});

final subscribeMarketSymbolsUseCaseProvider =
    Provider<SubscribeMarketSymbolsUseCase>((ref) {
  return SubscribeMarketSymbolsUseCase(ref.watch(marketRepositoryProvider));
});

final marketControllerProvider =
    NotifierProvider<MarketController, MarketState>(MarketController.new);
