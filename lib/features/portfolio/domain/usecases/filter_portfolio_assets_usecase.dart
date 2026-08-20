import '../entities/portfolio_asset.dart';
import '../entities/portfolio_filters.dart';

class FilterPortfolioAssetsUseCase {
  const FilterPortfolioAssetsUseCase();

  List<PortfolioAsset> call(
    List<PortfolioAsset> assets,
    PortfolioFilters filters,
  ) {
    final query = filters.query.trim().toLowerCase();
    final filtered = assets.where((asset) {
      final matchesQuery = query.isEmpty ||
          asset.symbol.toLowerCase().contains(query) ||
          asset.name.toLowerCase().contains(query);
      final matchesType = filters.type == null || asset.type == filters.type;
      final matchesFavorite = !filters.favoritesOnly || asset.isFavorite;
      return matchesQuery && matchesType && matchesFavorite;
    }).toList();

    filtered.sort((a, b) {
      final comparison = switch (filters.sortField) {
        PortfolioSortField.symbol => a.symbol.compareTo(b.symbol),
        PortfolioSortField.name => a.name.compareTo(b.name),
        PortfolioSortField.currentValue =>
          a.currentValue.compareTo(b.currentValue),
        PortfolioSortField.profitLoss => a.profitLoss.compareTo(b.profitLoss),
        PortfolioSortField.updatedAt => a.updatedAt.compareTo(b.updatedAt),
      };

      return filters.sortDirection == SortDirection.ascending
          ? comparison
          : -comparison;
    });

    return filtered;
  }
}
