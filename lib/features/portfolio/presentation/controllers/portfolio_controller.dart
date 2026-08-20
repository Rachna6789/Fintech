import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/portfolio_asset.dart';
import '../../domain/entities/portfolio_asset_input.dart';
import '../../domain/entities/portfolio_asset_type.dart';
import '../../domain/entities/portfolio_filters.dart';
import '../providers/portfolio_providers.dart';
import '../state/portfolio_state.dart';

class PortfolioController extends Notifier<PortfolioState> {
  StreamSubscription<List<PortfolioAsset>>? _subscription;

  @override
  PortfolioState build() {
    ref.onDispose(() => _subscription?.cancel());
    _watchAssets();
    return const PortfolioState.initial();
  }

  void setSearchQuery(String query) {
    _setFilters(state.filters.copyWith(query: query));
  }

  void setTypeFilter(PortfolioAssetType? type) {
    _setFilters(state.filters.copyWith(type: type, clearType: type == null));
  }

  void setFavoritesOnly(bool value) {
    _setFilters(state.filters.copyWith(favoritesOnly: value));
  }

  void setSort(PortfolioSortField field) {
    final nextDirection = state.filters.sortField == field &&
            state.filters.sortDirection == SortDirection.descending
        ? SortDirection.ascending
        : SortDirection.descending;
    _setFilters(
      state.filters.copyWith(sortField: field, sortDirection: nextDirection),
    );
  }

  Future<bool> addAsset(PortfolioAssetInput input) {
    return _runMutation(
        () => ref.read(addPortfolioAssetUseCaseProvider)(input));
  }

  Future<bool> updateAsset(String id, PortfolioAssetInput input) {
    return _runMutation(
      () => ref.read(updatePortfolioAssetUseCaseProvider)(id, input),
    );
  }

  Future<bool> deleteAsset(String id) {
    return _runMutation(
        () => ref.read(deletePortfolioAssetUseCaseProvider)(id));
  }

  Future<bool> toggleFavorite(PortfolioAsset asset) {
    return _runMutation(
      () => ref.read(togglePortfolioFavoriteUseCaseProvider)(
          asset.id, !asset.isFavorite),
    );
  }

  PortfolioAsset? assetById(String id) {
    for (final asset in state.assets) {
      if (asset.id == id) return asset;
    }
    return null;
  }

  void _watchAssets() {
    _subscription?.cancel();
    _subscription = ref.read(watchPortfolioAssetsUseCaseProvider)().listen(
      (assets) {
        state = state.copyWith(
          assets: assets,
          visibleAssets: _applyFilters(assets, state.filters),
          isLoading: false,
          clearError: true,
        );
      },
      onError: (Object error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  void _setFilters(PortfolioFilters filters) {
    state = state.copyWith(
      filters: filters,
      visibleAssets: _applyFilters(state.assets, filters),
    );
  }

  List<PortfolioAsset> _applyFilters(
    List<PortfolioAsset> assets,
    PortfolioFilters filters,
  ) {
    return ref.read(filterPortfolioAssetsUseCaseProvider)(assets, filters);
  }

  Future<bool> _runMutation(Future<Result<void>> Function() action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await action();
    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }
}
