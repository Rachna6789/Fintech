import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/market/data/datasources/market_search_local_data_source.dart';
import '../../features/portfolio/presentation/providers/portfolio_data_providers.dart';
import '../../features/profile/presentation/providers/profile_data_providers.dart';
import '../network/network_info.dart';
import '../services/hive_service.dart';
import '../settings/data/settings_local_data_source.dart';
import '../settings/providers/settings_providers.dart';
import 'offline_status.dart';
import 'offline_sync_service.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final service = OfflineSyncService(
    hiveService: ref.watch(hiveServiceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    portfolioRemoteDataSource: ref.watch(portfolioRemoteDataSourceProvider),
    portfolioLocalDataSource: ref.watch(portfolioLocalDataSourceProvider),
    settingsLocalDataSource: ref.watch(settingsLocalDataSourceProvider),
    profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final offlineStatusProvider =
    NotifierProvider<OfflineStatusNotifier, OfflineStatus>(
  OfflineStatusNotifier.new,
);

class OfflineStatusNotifier extends Notifier<OfflineStatus> {
  StreamSubscription<bool>? _connectivitySubscription;
  OfflineSyncService? _syncService;

  @override
  OfflineStatus build() {
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
      _syncService?.removeListener(_onStatusChanged);
    });
    _bootstrap();
    return const OfflineStatus.initial();
  }

  Future<void> _bootstrap() async {
    _syncService = ref.read(offlineSyncServiceProvider);
    _syncService!.addListener(_onStatusChanged);

    final networkInfo = ref.read(networkInfoProvider);
    final isOnline = await networkInfo.isConnected;
    final pending = await _syncService!.pendingCount();
    state = state.copyWith(isOnline: isOnline, pendingSyncCount: pending);

    _connectivitySubscription =
        networkInfo.onConnectivityChanged.listen((isConnected) async {
      state = state.copyWith(isOnline: isConnected);
      if (isConnected) {
        await _syncService!.syncPendingChanges();
      }
      final count = await _syncService!.pendingCount();
      state = state.copyWith(pendingSyncCount: count);
    });
  }

  void _onStatusChanged(OfflineStatus status) {
    state = status;
  }

  Future<void> syncNow() => _syncService?.syncPendingChanges() ?? Future.value();
}

final marketSearchLocalDataSourceProvider =
    Provider<MarketSearchLocalDataSource>((ref) {
  return MarketSearchLocalDataSource(ref.watch(hiveServiceProvider));
});
