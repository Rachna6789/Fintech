import 'market_asset_type.dart';

class MarketQuote {
  const MarketQuote({
    required this.symbol,
    required this.name,
    required this.type,
    required this.price,
    required this.changeAmount,
    required this.changePercent,
    required this.updatedAt,
  });

  final String symbol;
  final String name;
  final MarketAssetType type;
  final double price;
  final double changeAmount;
  final double changePercent;
  final DateTime updatedAt;

  bool get isPositive => changeAmount >= 0;

  MarketQuote copyWith({
    String? symbol,
    String? name,
    MarketAssetType? type,
    double? price,
    double? changeAmount,
    double? changePercent,
    DateTime? updatedAt,
  }) {
    return MarketQuote(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      changeAmount: changeAmount ?? this.changeAmount,
      changePercent: changePercent ?? this.changePercent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
