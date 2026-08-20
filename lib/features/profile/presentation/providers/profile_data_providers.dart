import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../data/datasources/profile_remote_data_source.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    storageService: ref.watch(firebaseStorageServiceProvider),
  );
});
