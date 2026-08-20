import 'portfolio_asset_type.dart';

class PortfolioAssetInput {
  const PortfolioAssetInput({
    required this.symbol,
    required this.name,
    required this.type,
    required this.quantity,
    required this.averageBuyPrice,
    required this.currentPrice,
    required this.isFavorite,
    this.notes,
  });

  final String symbol;
  final String name;
  final PortfolioAssetType type;
  final double quantity;
  final double averageBuyPrice;
  final double currentPrice;
  final bool isFavorite;
  final String? notes;
}
