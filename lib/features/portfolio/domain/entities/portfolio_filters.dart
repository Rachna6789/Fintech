import 'portfolio_asset_type.dart';

enum PortfolioSortField {
  symbol,
  name,
  currentValue,
  profitLoss,
  updatedAt;
}

enum SortDirection {
  ascending,
  descending;
}

class PortfolioFilters {
  const PortfolioFilters({
    this.query = '',
    this.type,
    this.favoritesOnly = false,
    this.sortField = PortfolioSortField.updatedAt,
    this.sortDirection = SortDirection.descending,
  });

  final String query;
  final PortfolioAssetType? type;
  final bool favoritesOnly;
  final PortfolioSortField sortField;
  final SortDirection sortDirection;

  PortfolioFilters copyWith({
    String? query,
    PortfolioAssetType? type,
    bool clearType = false,
    bool? favoritesOnly,
    PortfolioSortField? sortField,
    SortDirection? sortDirection,
  }) {
    return PortfolioFilters(
      query: query ?? this.query,
      type: clearType ? null : type ?? this.type,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}
