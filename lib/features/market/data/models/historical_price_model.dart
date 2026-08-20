import '../../domain/entities/historical_price.dart';

class HistoricalPriceModel extends HistoricalPrice {
  const HistoricalPriceModel({
    required super.timestamp,
    required super.price,
  });

  factory HistoricalPriceModel.fromJson(Map<String, dynamic> json) {
    return HistoricalPriceModel(
      timestamp: _date(json['timestamp']),
      price: _double(json['price']),
    );
  }

  factory HistoricalPriceModel.fromEntity(HistoricalPrice price) {
    return HistoricalPriceModel(
      timestamp: price.timestamp,
      price: price.price,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'price': price,
    };
  }

  static double _double(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _date(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
