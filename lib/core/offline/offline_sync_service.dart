// ignore_for_file: unused_field

import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../features/portfolio/data/datasources/portfolio_local_data_source.dart';
import '../../features/portfolio/data/datasources/portfolio_remote_data_source.dart';
import '../../features/portfolio/domain/entities/portfolio_asset_input.dart';
import '../../features/portfolio/domain/entities/portfolio_asset_type.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../network/network_info.dart';
import '../services/hive_service.dart';
import '../settings/data/settings_local_data_source.dart';
import '../storage/hive_boxes.dart';
import 'offline_action.dart';
import 'offline_status.dart';

typedef OfflineSyncListener = void Function(OfflineStatus status);

class OfflineSyncService {
  OfflineSyncService({
    required HiveService hiveService,
    required NetworkInfo networkInfo,
    required PortfolioRemoteDataSource portfolioRemoteDataSource,
    required PortfolioLocalDataSource portfolioLocalDataSource,
    required SettingsLocalDataSource settingsLocalDataSource,
    required ProfileRemoteDataSource profileRemoteDataSource,
  })  : _hiveService = hiveService,
        _networkInfo = networkInfo,
        _portfolioRemote = portfolioRemoteDataSource,
        _portfolioLocal = portfolioLocalDataSource,
        _settingsLocal = settingsLocalDataSource,
        _profileRemote = profileRemoteDataSource;

  final HiveService _hiveService;
  final NetworkInfo _networkInfo;
  final PortfolioRemoteDataSource _portfolioRemote;
  final PortfolioLocalDataSource _portfolioLocal;
  final SettingsLocalDataSource _settingsLocal;
  final ProfileRemoteDataSource _profileRemote;

  StreamSubscription<bool>? _connectivitySubscription;
  final List<OfflineSyncListener> _listeners = [];
  bool _isSyncing = false;
  bool _isInitialized = false;
  bool _isOnline = true;
  int _pendingCount = 0;
  DateTime? _lastSyncedAt;

  void addListener(OfflineSyncListener listener) {
    _listeners.add(listener);
  }

  void removeListener(OfflineSyncListener listener) {
    _listeners.remove(listener);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _hiveService.initialize();

    _isOnline = await _networkInfo.isConnected;
    _pendingCount = await pendingCount();

    _connectivitySubscription =
        _networkInfo.onConnectivityChanged.listen((isConnected) {
      _isOnline = isConnected;
      _notify();
      if (isConnected) {
        unawaited(syncPendingChanges());
      }
    });

    if (_isOnline) {
      unawaited(syncPendingChanges());
    }

    _isInitialized = true;
    _notify();
  }

  Future<int> pendingCount() async {
    final box = await _queueBox();
    return box.length;
  }

  Future<void> enqueue({
    required String action,
    required String entity,
    required Map<String, dynamic> payload,
  }) async {
    final box = await _queueBox();
    await box.add(
      OfflineAction(
        action: action,
        entity: entity,
        payload: payload,
        createdAt: DateTime.now(),
      ).toJson(),
    );
    _pendingCount = box.length;
    _notify();
  }

  Future<void> syncPendingChanges() async {
    if (_isSyncing) return;
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) return;

    _isSyncing = true;
    _notify();

    try {
      final box = await _queueBox();
      final pending = box.values
          .whereType<Map>()
          .map((item) => OfflineAction.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);

      for (final item in pending) {
        await _processPendingItem(item);
      }

      await box.clear();
      await _refreshCachesFromRemote();
      _pendingCount = 0;
      _lastSyncedAt = DateTime.now();
    } finally {
      _isSyncing = false;
      _notify();
    }
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _listeners.clear();
  }

  Future<void> _refreshCachesFromRemote() async {
    try {
      final assets = await _portfolioRemote.getAssets();
      await _portfolioLocal.saveAssets(assets);
    } catch (_) {
      // Keep local cache when remote refresh fails.
    }

    try {
      await _refreshProfileFromRemote();
    } catch (_) {
      // Ignore profile refresh failures.
    }
  }

  Future<void> _processPendingItem(OfflineAction item) async {
    switch (item.entity) {
      case OfflineEntities.portfolio:
        await _processPortfolioAction(item);
      case OfflineEntities.settings:
        await _processSettingsAction(item);
    }
  }

  Future<void> _processPortfolioAction(OfflineAction item) async {
    switch (item.action) {
      case OfflineActions.add:
        final input = _portfolioInputFromJson(item.payload);
        await _portfolioRemote.addAsset(input);
      case OfflineActions.update:
        final id = item.payload['id'] as String?;
        final input = _portfolioInputFromJson(item.payload);
        if (id != null && !id.startsWith('pending_')) {
          await _portfolioRemote.updateAsset(id, input);
        }
      case OfflineActions.delete:
        final id = item.payload['id'] as String?;
        if (id != null && !id.startsWith('pending_')) {
          await _portfolioRemote.deleteAsset(id);
        }
      case OfflineActions.toggleFavorite:
        final id = item.payload['id'] as String?;
        final isFavorite = item.payload['isFavorite'] as bool? ?? false;
        if (id != null && !id.startsWith('pending_')) {
          await _portfolioRemote.toggleFavorite(id, isFavorite);
        }
    }
  }

  Future<void> _processSettingsAction(OfflineAction item) async {
    if (item.action != OfflineActions.patch) return;
    await _settingsLocal.patchSettings(
      baseCurrency: item.payload['baseCurrency'] as String?,
      isDarkMode: item.payload['isDarkMode'] as bool?,
      notificationsEnabled: item.payload['notificationsEnabled'] as bool?,
      biometricEnabled: item.payload['biometricEnabled'] as bool?,
      marketSymbols: (item.payload['marketSymbols'] as List?)
          ?.whereType<String>()
          .toList(growable: false),
    );
  }

  Future<void> _refreshProfileFromRemote() async {
    final profile = await _profileRemote.getProfile();
    if (profile != null) {
      await _settingsLocal.patchSettings(
        baseCurrency: profile.baseCurrency,
        isDarkMode: profile.isDarkMode,
        notificationsEnabled: profile.notificationsEnabled,
        biometricEnabled: profile.biometricEnabled,
      );
    }
  }

  PortfolioAssetInput _portfolioInputFromJson(Map<String, dynamic> payload) {
    final input = payload['input'];
    final map = input is Map
        ? Map<String, dynamic>.from(input)
        : Map<String, dynamic>.from(payload);

    return PortfolioAssetInput(
      symbol: map['symbol'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: _portfolioType(map['type']),
      quantity: _double(map['quantity']),
      averageBuyPrice: _double(map['averageBuyPrice']),
      currentPrice: _double(map['currentPrice']),
      isFavorite: map['isFavorite'] as bool? ?? false,
      notes: map['notes'] as String?,
    );
  }

  PortfolioAssetType _portfolioType(Object? value) {
    final name = value as String?;
    return PortfolioAssetType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => PortfolioAssetType.other,
    );
  }

  double _double(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<Box<dynamic>> _queueBox() async {
    if (!Hive.isBoxOpen(HiveBoxes.offlineQueue)) {
      return _hiveService.openBox<dynamic>(HiveBoxes.offlineQueue);
    }
    return _hiveService.box<dynamic>(HiveBoxes.offlineQueue);
  }

  void _notify() {
    final status = OfflineStatus(
      isOnline: _isOnline,
      pendingSyncCount: _pendingCount,
      isSyncing: _isSyncing,
      lastSyncedAt: _lastSyncedAt,
    );
    for (final listener in List<OfflineSyncListener>.from(_listeners)) {
      listener(status);
    }
  }
}
