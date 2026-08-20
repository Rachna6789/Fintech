import '../../../../core/errors/result.dart';
import '../entities/portfolio_asset.dart';
import '../entities/portfolio_asset_input.dart';

abstract interface class PortfolioRepository {
  Stream<List<PortfolioAsset>> watchAssets();

  Future<Result<List<PortfolioAsset>>> getAssets();

  Future<Result<PortfolioAsset>> getAsset(String id);

  Future<Result<void>> addAsset(PortfolioAssetInput input);

  Future<Result<void>> updateAsset(String id, PortfolioAssetInput input);

  Future<Result<void>> deleteAsset(String id);

  Future<Result<void>> toggleFavorite(String id, bool isFavorite);
}
