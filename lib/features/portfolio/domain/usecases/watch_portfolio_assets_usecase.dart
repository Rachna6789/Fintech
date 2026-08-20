import '../entities/portfolio_asset.dart';
import '../repositories/portfolio_repository.dart';

class WatchPortfolioAssetsUseCase {
  const WatchPortfolioAssetsUseCase(this._repository);

  final PortfolioRepository _repository;

  Stream<List<PortfolioAsset>> call() => _repository.watchAssets();
}
