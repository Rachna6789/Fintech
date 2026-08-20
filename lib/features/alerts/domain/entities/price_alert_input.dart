import 'price_alert_condition.dart';

class PriceAlertInput {
  const PriceAlertInput({
    required this.symbol,
    required this.assetName,
    required this.targetPrice,
    required this.condition,
    this.isEnabled = true,
  });

  final String symbol;
  final String assetName;
  final double targetPrice;
  final PriceAlertCondition condition;
  final bool isEnabled;
}
