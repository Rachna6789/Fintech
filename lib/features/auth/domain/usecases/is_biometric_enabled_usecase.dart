import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

class IsBiometricEnabledUseCase {
  const IsBiometricEnabledUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<bool>> call() => _repository.isBiometricEnabled();
}
