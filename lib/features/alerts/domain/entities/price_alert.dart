import 'price_alert_condition.dart';

class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.symbol,
    required this.assetName,
    required this.targetPrice,
    required this.condition,
    required this.isEnabled,
    required this.hasTriggered,
    required this.createdAt,
    required this.updatedAt,
    this.lastTriggeredAt,
  });

  final String id;
  final String symbol;
  final String assetName;
  final double targetPrice;
  final PriceAlertCondition condition;
  final bool isEnabled;
  final bool hasTriggered;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastTriggeredAt;

  String get triggerDescription {
    return '$symbol ${condition.label.toLowerCase()} $targetPrice';
  }

  bool shouldTriggerAt(double price) {
    return switch (condition) {
      PriceAlertCondition.above => price > targetPrice,
      PriceAlertCondition.below => price < targetPrice,
    };
  }
}
