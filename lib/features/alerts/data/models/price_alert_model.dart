import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/price_alert.dart';
import '../../domain/entities/price_alert_condition.dart';
import '../../domain/entities/price_alert_input.dart';

class PriceAlertModel extends PriceAlert {
  const PriceAlertModel({
    required super.id,
    required super.symbol,
    required super.assetName,
    required super.targetPrice,
    required super.condition,
    required super.isEnabled,
    required super.hasTriggered,
    required super.createdAt,
    required super.updatedAt,
    super.lastTriggeredAt,
  });

  factory PriceAlertModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return PriceAlertModel(
      id: document.id,
      symbol: data['symbol'] as String? ?? '',
      assetName: data['assetName'] as String? ?? '',
      targetPrice: _double(data['targetPrice']),
      condition: _condition(data['condition']),
      isEnabled: data['isEnabled'] as bool? ?? true,
      hasTriggered: data['hasTriggered'] as bool? ?? false,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
      lastTriggeredAt: _nullableDate(data['lastTriggeredAt']),
    );
  }

  static Map<String, dynamic> createJson({
    required PriceAlertInput input,
    required String userId,
  }) {
    final symbol = input.symbol.trim().toUpperCase();
    return {
      'userId': userId,
      'symbol': symbol,
      'assetName': input.assetName.trim(),
      'targetPrice': input.targetPrice,
      'condition': input.condition.name,
      'isEnabled': input.isEnabled,
      'hasTriggered': false,
      'lastTriggeredAt': null,
      'notificationTitle': 'Price alert: $symbol',
      'notificationBody':
          '$symbol is ${input.condition.label.toLowerCase()} ${input.targetPrice.toStringAsFixed(2)}.',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static PriceAlertCondition _condition(Object? value) {
    final name = value as String?;
    return PriceAlertCondition.values.firstWhere(
      (condition) => condition.name == name,
      orElse: () => PriceAlertCondition.above,
    );
  }

  static double _double(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _date(Object? value) {
    return _nullableDate(value) ?? DateTime.now();
  }

  static DateTime? _nullableDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
