import '../../../../core/errors/result.dart';
import '../entities/portfolio_asset_input.dart';
import '../repositories/portfolio_repository.dart';

class AddPortfolioAssetUseCase {
  const AddPortfolioAssetUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<Result<void>> call(PortfolioAssetInput input) {
    return _repository.addAsset(input);
  }
}
