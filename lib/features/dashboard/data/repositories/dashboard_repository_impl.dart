import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Stream<DashboardSummary> watchDashboard() {
    return _remoteDataSource.watchDashboard();
  }

  @override
  Future<Result<DashboardSummary>> getDashboard() async {
    try {
      return Success(await _remoteDataSource.getDashboard());
    } catch (error) {
      final Failure failure = ErrorMapper.toFailure(error);
      return FailureResult<DashboardSummary>(failure);
    }
  }
}
