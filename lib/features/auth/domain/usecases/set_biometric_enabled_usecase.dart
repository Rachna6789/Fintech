import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

class SetBiometricEnabledUseCase {
  const SetBiometricEnabledUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(bool enabled) {
    return _repository.setBiometricEnabled(enabled);
  }
}
