import '../../domain/entities/market_asset_type.dart';
import '../../domain/entities/market_quote.dart';

class MarketQuoteModel extends MarketQuote {
  const MarketQuoteModel({
    required super.symbol,
    required super.name,
    required super.type,
    required super.price,
    required super.changeAmount,
    required super.changePercent,
    required super.updatedAt,
  });

  factory MarketQuoteModel.fromJson(Map<String, dynamic> json) {
    return MarketQuoteModel(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _type(json['type']),
      price: _double(json['price']),
      changeAmount: _double(json['changeAmount']),
      changePercent: _double(json['changePercent']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  factory MarketQuoteModel.fromEntity(MarketQuote quote) {
    return MarketQuoteModel(
      symbol: quote.symbol,
      name: quote.name,
      type: quote.type,
      price: quote.price,
      changeAmount: quote.changeAmount,
      changePercent: quote.changePercent,
      updatedAt: quote.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'type': type.name,
      'price': price,
      'changeAmount': changeAmount,
      'changePercent': changePercent,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static MarketAssetType _type(Object? value) {
    final name = (value as String?)?.toLowerCase();
    return MarketAssetType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => MarketAssetType.stock,
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
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
