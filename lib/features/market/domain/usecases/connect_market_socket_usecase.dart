import '../../../../core/errors/result.dart';
import '../repositories/market_repository.dart';

class ConnectMarketSocketUseCase {
  const ConnectMarketSocketUseCase(this._repository);

  final MarketRepository _repository;

  Future<Result<void>> call() => _repository.connect();
}
