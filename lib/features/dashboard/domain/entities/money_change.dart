class MoneyChange {
  const MoneyChange({
    required this.amount,
    required this.percent,
  });

  final double amount;
  final double percent;

  bool get isPositive => amount >= 0;
}
