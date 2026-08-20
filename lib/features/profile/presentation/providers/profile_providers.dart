import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/offline/offline_providers.dart';
import '../../../../core/settings/providers/settings_providers.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';
import '../state/profile_state.dart';
import 'profile_data_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    dataSource: ref.watch(profileRemoteDataSourceProvider),
    settingsLocalDataSource: ref.watch(settingsLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    offlineSyncService: ref.watch(offlineSyncServiceProvider),
  );
});

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController(ref.watch(profileRepositoryProvider));
});
