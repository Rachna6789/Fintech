import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
