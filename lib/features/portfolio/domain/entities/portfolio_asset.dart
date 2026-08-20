import 'portfolio_asset_type.dart';

class PortfolioAsset {
  const PortfolioAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.type,
    required this.quantity,
    required this.averageBuyPrice,
    required this.currentPrice,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String symbol;
  final String name;
  final PortfolioAssetType type;
  final double quantity;
  final double averageBuyPrice;
  final double currentPrice;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  double get investedValue => quantity * averageBuyPrice;
  double get currentValue => quantity * currentPrice;
  double get profitLoss => currentValue - investedValue;
  double get profitLossPercent {
    if (investedValue <= 0) return 0;
    return (profitLoss / investedValue) * 100;
  }

  PortfolioAsset copyWith({
    String? id,
    String? symbol,
    String? name,
    PortfolioAssetType? type,
    double? quantity,
    double? averageBuyPrice,
    double? currentPrice,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return PortfolioAsset(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
