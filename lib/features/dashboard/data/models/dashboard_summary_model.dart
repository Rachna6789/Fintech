import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/allocation_slice.dart';
import '../../domain/entities/asset_performance.dart';
import '../../domain/entities/chart_point.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/market_overview_item.dart';
import '../../domain/entities/money_change.dart';
import '../../domain/entities/recent_activity.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.portfolioValue,
    required super.todaysProfit,
    required super.overallProfit,
    required super.topGainers,
    required super.topLosers,
    required super.allocation,
    required super.recentActivity,
    required super.marketOverview,
    required super.portfolioChart,
    required super.updatedAt,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      portfolioValue: _double(json['portfolioValue']),
      todaysProfit: MoneyChange(
        amount: _double(json['todaysProfitAmount']),
        percent: _double(json['todaysProfitPercent']),
      ),
      overallProfit: MoneyChange(
        amount: _double(json['overallProfitAmount']),
        percent: _double(json['overallProfitPercent']),
      ),
      topGainers: _list(json['topGainers'])
          .map((item) => _assetPerformance(item))
          .toList(growable: false),
      topLosers: _list(json['topLosers'])
          .map((item) => _assetPerformance(item))
          .toList(growable: false),
      allocation: _list(json['allocation'])
          .map((item) => AllocationSlice(
                label: item['label'] as String? ?? 'Other',
                value: _double(item['value']),
                percent: _double(item['percent']),
              ))
          .toList(growable: false),
      recentActivity: _list(json['recentActivity'])
          .map((item) => RecentActivity(
                id: item['id'] as String? ?? '',
                title: item['title'] as String? ?? 'Activity',
                subtitle: item['subtitle'] as String? ?? '',
                amount: _double(item['amount']),
                occurredAt: _date(item['occurredAt']),
              ))
          .toList(growable: false),
      marketOverview: _list(json['marketOverview'])
          .map((item) => MarketOverviewItem(
                symbol: item['symbol'] as String? ?? '',
                name: item['name'] as String? ?? '',
                value: _double(item['value']),
                changePercent: _double(item['changePercent']),
              ))
          .toList(growable: false),
      portfolioChart: _list(json['portfolioChart'])
          .map((item) => ChartPoint(
                timestamp: _date(item['timestamp']),
                value: _double(item['value']),
              ))
          .toList(growable: false),
      updatedAt: _date(json['updatedAt']),
    );
  }

  static AssetPerformance _assetPerformance(Map<String, dynamic> item) {
    return AssetPerformance(
      symbol: item['symbol'] as String? ?? '',
      name: item['name'] as String? ?? '',
      price: _double(item['price']),
      changePercent: _double(item['changePercent']),
      changeAmount: _double(item['changeAmount']),
    );
  }

  static List<Map<String, dynamic>> _list(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  static double _double(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
