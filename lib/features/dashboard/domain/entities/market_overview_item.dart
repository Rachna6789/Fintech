class MarketOverviewItem {
  const MarketOverviewItem({
    required this.symbol,
    required this.name,
    required this.value,
    required this.changePercent,
  });

  final String symbol;
  final String name;
  final double value;
  final double changePercent;

  bool get isPositive => changePercent >= 0;
}
