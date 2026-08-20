import '../../../../core/errors/result.dart';
import '../entities/portfolio_asset.dart';
import '../repositories/portfolio_repository.dart';

class GetPortfolioAssetUseCase {
  const GetPortfolioAssetUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<Result<PortfolioAsset>> call(String id) => _repository.getAsset(id);
}
