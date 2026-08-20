import '../../../../core/errors/result.dart';
import '../entities/dashboard_summary.dart';

abstract interface class DashboardRepository {
  Stream<DashboardSummary> watchDashboard();

  Future<Result<DashboardSummary>> getDashboard();
}
