import 'dart:async';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/offline/offline_action.dart';
import '../../../../core/offline/offline_sync_service.dart';
import '../../domain/entities/portfolio_asset.dart';
import '../../domain/entities/portfolio_asset_input.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_data_source.dart';
import '../datasources/portfolio_remote_data_source.dart';
import '../models/portfolio_asset_model.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl({
    required PortfolioRemoteDataSource remoteDataSource,
    required PortfolioLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required OfflineSyncService offlineSyncService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo,
        _offlineSyncService = offlineSyncService;

  final PortfolioRemoteDataSource _remoteDataSource;
  final PortfolioLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final OfflineSyncService _offlineSyncService;

  StreamSubscription<List<PortfolioAsset>>? _remoteSubscription;

  @override
  Stream<List<PortfolioAsset>> watchAssets() {
    _startRemoteSync();
    return _localDataSource.watchAssets();
  }

  @override
  Future<Result<List<PortfolioAsset>>> getAssets() async {
    if (await _networkInfo.isConnected) {
      try {
        final assets = await _remoteDataSource.getAssets();
        await _localDataSource.saveAssets(assets);
        return Success(assets);
      } catch (error) {
        final cached = await _localDataSource.readAssets();
        if (cached.isNotEmpty) return Success(cached);
        return FailureResult(ErrorMapper.toFailure(error));
      }
    }
    return Success(await _localDataSource.readAssets());
  }

  @override
  Future<Result<PortfolioAsset>> getAsset(String id) async {
    final cached = await _localDataSource.readAssets();
    PortfolioAsset? match;
    for (final asset in cached) {
      if (asset.id == id) {
        match = asset;
        break;
      }
    }
    if (match != null) return Success(match);

    if (!await _networkInfo.isConnected) {
      return const FailureResult(CacheFailure(message: 'Asset not found in cache.'));
    }

    return _guard(() => _remoteDataSource.getAsset(id));
  }

  @override
  Future<Result<void>> addAsset(PortfolioAssetInput input) async {
    final localId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final asset = PortfolioAssetModel.fromInput(id: localId, input: input);
    await _localDataSource.upsertAsset(asset);

    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.addAsset(input);
        final assets = await _remoteDataSource.getAssets();
        await _localDataSource.saveAssets(assets);
        return const Success(null);
      } catch (error) {
        await _offlineSyncService.enqueue(
          action: OfflineActions.add,
          entity: OfflineEntities.portfolio,
          payload: {'input': PortfolioAssetModel.inputToJson(input)},
        );
        return const Success(null);
      }
    }

    await _offlineSyncService.enqueue(
      action: OfflineActions.add,
      entity: OfflineEntities.portfolio,
      payload: {'input': PortfolioAssetModel.inputToJson(input)},
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> updateAsset(String id, PortfolioAssetInput input) async {
    final assets = await _localDataSource.readAssets();
    PortfolioAsset? existing;
    for (final asset in assets) {
      if (asset.id == id) {
        existing = asset;
        break;
      }
    }
    if (existing != null) {
      await _localDataSource.upsertAsset(
        existing.copyWith(
          symbol: input.symbol.trim().toUpperCase(),
          name: input.name.trim(),
          type: input.type,
          quantity: input.quantity,
          averageBuyPrice: input.averageBuyPrice,
          currentPrice: input.currentPrice,
          isFavorite: input.isFavorite,
          notes: input.notes?.trim(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    if (await _networkInfo.isConnected && !id.startsWith('pending_')) {
      try {
        await _remoteDataSource.updateAsset(id, input);
        return const Success(null);
      } catch (error) {
        await _enqueueUpdate(id, input);
        return const Success(null);
      }
    }

    if (!id.startsWith('pending_')) {
      await _enqueueUpdate(id, input);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAsset(String id) async {
    await _localDataSource.removeAsset(id);

    if (await _networkInfo.isConnected && !id.startsWith('pending_')) {
      try {
        await _remoteDataSource.deleteAsset(id);
        return const Success(null);
      } catch (error) {
        await _offlineSyncService.enqueue(
          action: OfflineActions.delete,
          entity: OfflineEntities.portfolio,
          payload: {'id': id},
        );
        return const Success(null);
      }
    }

    if (!id.startsWith('pending_')) {
      await _offlineSyncService.enqueue(
        action: OfflineActions.delete,
        entity: OfflineEntities.portfolio,
        payload: {'id': id},
      );
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> toggleFavorite(String id, bool isFavorite) async {
    final assets = await _localDataSource.readAssets();
    PortfolioAsset? existing;
    for (final asset in assets) {
      if (asset.id == id) {
        existing = asset;
        break;
      }
    }
    if (existing != null) {
      await _localDataSource.upsertAsset(
        existing.copyWith(isFavorite: isFavorite, updatedAt: DateTime.now()),
      );
    }

    if (await _networkInfo.isConnected && !id.startsWith('pending_')) {
      try {
        await _remoteDataSource.toggleFavorite(id, isFavorite);
        return const Success(null);
      } catch (error) {
        await _enqueueToggleFavorite(id, isFavorite);
        return const Success(null);
      }
    }

    if (!id.startsWith('pending_')) {
      await _enqueueToggleFavorite(id, isFavorite);
    }
    return const Success(null);
  }

  Future<void> _enqueueUpdate(String id, PortfolioAssetInput input) {
    return _offlineSyncService.enqueue(
      action: OfflineActions.update,
      entity: OfflineEntities.portfolio,
      payload: {
        'id': id,
        'input': PortfolioAssetModel.inputToJson(input),
      },
    );
  }

  Future<void> _enqueueToggleFavorite(String id, bool isFavorite) {
    return _offlineSyncService.enqueue(
      action: OfflineActions.toggleFavorite,
      entity: OfflineEntities.portfolio,
      payload: {'id': id, 'isFavorite': isFavorite},
    );
  }

  void _startRemoteSync() {
    if (_remoteSubscription != null) return;
    unawaited(_bindRemoteSync());
  }

  Future<void> _bindRemoteSync() async {
    if (!await _networkInfo.isConnected) return;
    _remoteSubscription?.cancel();
    _remoteSubscription = _remoteDataSource.watchAssets().listen(
      (assets) => _localDataSource.saveAssets(assets),
      onError: (_) {},
    );
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
