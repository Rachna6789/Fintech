import '../../../../core/errors/result.dart';
import '../repositories/portfolio_repository.dart';

class TogglePortfolioFavoriteUseCase {
  const TogglePortfolioFavoriteUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<Result<void>> call(String id, bool isFavorite) {
    return _repository.toggleFavorite(id, isFavorite);
  }
}
