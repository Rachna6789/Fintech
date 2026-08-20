import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/offline/offline_providers.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../domain/usecases/add_portfolio_asset_usecase.dart';
import '../../domain/usecases/delete_portfolio_asset_usecase.dart';
import '../../domain/usecases/filter_portfolio_assets_usecase.dart';
import '../../domain/usecases/get_portfolio_asset_usecase.dart';
import '../../domain/usecases/toggle_portfolio_favorite_usecase.dart';
import '../../domain/usecases/update_portfolio_asset_usecase.dart';
import '../../domain/usecases/watch_portfolio_assets_usecase.dart';
import '../controllers/portfolio_controller.dart';
import '../state/portfolio_state.dart';
import 'portfolio_data_providers.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepositoryImpl(
    remoteDataSource: ref.watch(portfolioRemoteDataSourceProvider),
    localDataSource: ref.watch(portfolioLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    offlineSyncService: ref.watch(offlineSyncServiceProvider),
  );
});

final watchPortfolioAssetsUseCaseProvider =
    Provider<WatchPortfolioAssetsUseCase>((ref) {
  return WatchPortfolioAssetsUseCase(ref.watch(portfolioRepositoryProvider));
});

final getPortfolioAssetUseCaseProvider =
    Provider<GetPortfolioAssetUseCase>((ref) {
  return GetPortfolioAssetUseCase(ref.watch(portfolioRepositoryProvider));
});

final addPortfolioAssetUseCaseProvider =
    Provider<AddPortfolioAssetUseCase>((ref) {
  return AddPortfolioAssetUseCase(ref.watch(portfolioRepositoryProvider));
});

final updatePortfolioAssetUseCaseProvider =
    Provider<UpdatePortfolioAssetUseCase>((ref) {
  return UpdatePortfolioAssetUseCase(ref.watch(portfolioRepositoryProvider));
});

final deletePortfolioAssetUseCaseProvider =
    Provider<DeletePortfolioAssetUseCase>((ref) {
  return DeletePortfolioAssetUseCase(ref.watch(portfolioRepositoryProvider));
});

final togglePortfolioFavoriteUseCaseProvider =
    Provider<TogglePortfolioFavoriteUseCase>((ref) {
  return TogglePortfolioFavoriteUseCase(ref.watch(portfolioRepositoryProvider));
});

final filterPortfolioAssetsUseCaseProvider =
    Provider<FilterPortfolioAssetsUseCase>((ref) {
  return const FilterPortfolioAssetsUseCase();
});

final portfolioControllerProvider =
    NotifierProvider<PortfolioController, PortfolioState>(
  PortfolioController.new,
);
