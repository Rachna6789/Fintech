import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import '../../domain/usecases/watch_dashboard_usecase.dart';

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

final getDashboardUseCaseProvider = Provider<GetDashboardUseCase>((ref) {
  return GetDashboardUseCase(ref.watch(dashboardRepositoryProvider));
});

final watchDashboardUseCaseProvider = Provider<WatchDashboardUseCase>((ref) {
  return WatchDashboardUseCase(ref.watch(dashboardRepositoryProvider));
});

final dashboardSummaryProvider = StreamProvider<DashboardSummary>((ref) {
  return ref.watch(watchDashboardUseCaseProvider)();
});
