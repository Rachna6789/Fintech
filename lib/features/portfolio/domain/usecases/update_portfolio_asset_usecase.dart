import '../../../../core/errors/result.dart';
import '../entities/portfolio_asset_input.dart';
import '../repositories/portfolio_repository.dart';

class UpdatePortfolioAssetUseCase {
  const UpdatePortfolioAssetUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<Result<void>> call(String id, PortfolioAssetInput input) {
    return _repository.updateAsset(id, input);
  }
}
