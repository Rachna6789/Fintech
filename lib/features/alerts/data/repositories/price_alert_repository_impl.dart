import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/entities/price_alert_input.dart';
import '../../domain/repositories/price_alert_repository.dart';
import '../datasources/price_alert_remote_data_source.dart';

class PriceAlertRepositoryImpl implements PriceAlertRepository {
  const PriceAlertRepositoryImpl(this._remoteDataSource);

  final PriceAlertRemoteDataSource _remoteDataSource;

  @override
  Stream<List<PriceAlert>> watchAlerts() => _remoteDataSource.watchAlerts();

  @override
  Future<Result<void>> createAlert(PriceAlertInput input) {
    return _guard(() => _remoteDataSource.createAlert(input));
  }

  @override
  Future<Result<void>> deleteAlert(String id) {
    return _guard(() => _remoteDataSource.deleteAlert(id));
  }

  @override
  Future<Result<void>> setAlertEnabled(String id, bool enabled) {
    return _guard(() => _remoteDataSource.setAlertEnabled(id, enabled));
  }

  @override
  Future<Result<void>> triggerAlert(String id, double currentPrice) {
    return _guard(() => _remoteDataSource.triggerAlert(id, currentPrice));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      final Failure failure = ErrorMapper.toFailure(error);
      return FailureResult<T>(failure);
    }
  }
}
