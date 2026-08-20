import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../entities/profile_setup_data.dart';
import '../repositories/auth_repository.dart';

class CompleteProfileSetupUseCase {
  const CompleteProfileSetupUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call(ProfileSetupData data) {
    return _repository.completeProfileSetup(data);
  }
}
