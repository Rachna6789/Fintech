import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentAuthUserUseCase {
  const GetCurrentAuthUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser?>> call() => _repository.getCurrentUser();
}
