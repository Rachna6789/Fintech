import '../../../../core/errors/result.dart';
import '../repositories/portfolio_repository.dart';

class DeletePortfolioAssetUseCase {
  const DeletePortfolioAssetUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteAsset(id);
}
