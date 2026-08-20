import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/hive_service.dart';
import '../../data/datasources/portfolio_local_data_source.dart';
import '../../data/datasources/portfolio_remote_data_source.dart';

final portfolioRemoteDataSourceProvider =
    Provider<PortfolioRemoteDataSource>((ref) {
  return PortfolioRemoteDataSource(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final portfolioLocalDataSourceProvider =
    Provider<PortfolioLocalDataSource>((ref) {
  return PortfolioLocalDataSource(ref.watch(hiveServiceProvider));
});
