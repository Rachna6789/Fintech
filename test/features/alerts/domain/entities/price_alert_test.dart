import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/alerts/domain/entities/price_alert.dart';
import 'package:fintrack/features/alerts/domain/entities/price_alert_condition.dart';

void main() {
  group('PriceAlert', () {
    test('detects when a price crosses the configured threshold', () {
      const alert = PriceAlert(
        id: '1',
        symbol: 'AAPL',
        assetName: 'Apple',
        targetPrice: 200,
        condition: PriceAlertCondition.above,
        isEnabled: true,
        hasTriggered: false,
        createdAt: null,
        updatedAt: null,
      );

      expect(alert.shouldTriggerAt(205), isTrue);
      expect(alert.shouldTriggerAt(199), isFalse);
    });
  });
}
