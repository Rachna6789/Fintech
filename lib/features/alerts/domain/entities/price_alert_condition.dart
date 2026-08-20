enum PriceAlertCondition {
  above,
  below;

  String get label => switch (this) {
        PriceAlertCondition.above => 'Above',
        PriceAlertCondition.below => 'Below',
      };
}
