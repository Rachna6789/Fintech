import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/services/hive_service.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../domain/entities/historical_price.dart';
import '../../domain/entities/market_quote.dart';
import '../models/historical_price_model.dart';
import '../models/market_quote_model.dart';

class MarketLocalDataSource {
  const MarketLocalDataSource(this._hiveService);

  static const _quotesKey = 'quotes';
  static const _historyPrefix = 'history_';
  static const _lastSyncedKey = 'last_synced_at';

  final HiveService _hiveService;

  Future<List<MarketQuote>> readQuotes() async {
    final box = await _box();
    final value = box.get(_quotesKey);
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((item) =>
            MarketQuoteModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> saveQuotes(List<MarketQuote> quotes) async {
    final box = await _box();
    final json = quotes
        .map((quote) => MarketQuoteModel.fromEntity(quote).toJson())
        .toList(growable: false);
    await box.put(_quotesKey, json);
    await box.put(_lastSyncedKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> readLastSyncedAt() async {
    final box = await _box();
    final value = box.get(_lastSyncedKey);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Future<List<HistoricalPrice>> readHistory(String symbol) async {
    final box = await _box();
    final value = box.get('$_historyPrefix$symbol');
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map(
          (item) =>
              HistoricalPriceModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<void> saveHistory(String symbol, List<HistoricalPrice> prices) async {
    final box = await _box();
    final json = prices
        .map((price) => HistoricalPriceModel.fromEntity(price).toJson())
        .toList(growable: false);
    await box.put('$_historyPrefix$symbol', json);
  }

  Future<Box<dynamic>> _box() async {
    if (!Hive.isBoxOpen(HiveBoxes.market)) {
      return _hiveService.openBox<dynamic>(HiveBoxes.market);
    }
    return _hiveService.box<dynamic>(HiveBoxes.market);
  }
}
