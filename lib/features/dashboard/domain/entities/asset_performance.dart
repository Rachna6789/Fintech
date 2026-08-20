class AssetPerformance {
  const AssetPerformance({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.changeAmount,
  });

  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final double changeAmount;

  bool get isPositive => changeAmount >= 0;
}
