import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerificationUseCase {
  const SendEmailVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.sendEmailVerification();
}
