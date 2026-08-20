import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class WatchDashboardUseCase {
  const WatchDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  Stream<DashboardSummary> call() => _repository.watchDashboard();
}
