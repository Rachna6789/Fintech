import '../../../../core/errors/result.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase {
  const GetDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Result<DashboardSummary>> call() => _repository.getDashboard();
}
