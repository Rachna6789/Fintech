import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/historical_price.dart';
import '../../domain/entities/market_quote.dart';
import '../models/historical_price_model.dart';
import '../models/market_quote_model.dart';

class MarketRemoteDataSource {
  const MarketRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MarketQuote>> fetchQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return const [];

    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.marketQuotes,
      queryParameters: {'symbols': symbols.join(',')},
    );
    final payload = response.data?['data'];
    final items = payload is List ? payload : const [];
    return items
        .whereType<Map>()
        .map((item) =>
            MarketQuoteModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<HistoricalPrice>> fetchHistory(String symbol) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.historicalPrices,
      queryParameters: {'symbol': symbol},
    );
    final payload = response.data?['data'];
    final items = payload is List ? payload : const [];
    return items
        .whereType<Map>()
        .map(
          (item) =>
              HistoricalPriceModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }
}
