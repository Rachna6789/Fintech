import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class ReloadAuthUserUseCase {
  const ReloadAuthUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser?>> call() => _repository.reloadCurrentUser();
}
