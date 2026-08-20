import '../../domain/entities/portfolio_asset.dart';
import '../../domain/entities/portfolio_filters.dart';

class PortfolioState {
  const PortfolioState({
    required this.assets,
    required this.visibleAssets,
    required this.filters,
    this.isLoading = false,
    this.errorMessage,
  });

  const PortfolioState.initial()
      : assets = const [],
        visibleAssets = const [],
        filters = const PortfolioFilters(),
        isLoading = true,
        errorMessage = null;

  final List<PortfolioAsset> assets;
  final List<PortfolioAsset> visibleAssets;
  final PortfolioFilters filters;
  final bool isLoading;
  final String? errorMessage;

  double get totalValue {
    return assets.fold(0, (sum, asset) => sum + asset.currentValue);
  }

  double get totalProfitLoss {
    return assets.fold(0, (sum, asset) => sum + asset.profitLoss);
  }

  PortfolioState copyWith({
    List<PortfolioAsset>? assets,
    List<PortfolioAsset>? visibleAssets,
    PortfolioFilters? filters,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PortfolioState(
      assets: assets ?? this.assets,
      visibleAssets: visibleAssets ?? this.visibleAssets,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
