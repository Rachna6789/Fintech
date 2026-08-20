import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
