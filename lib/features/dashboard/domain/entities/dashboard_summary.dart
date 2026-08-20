import 'allocation_slice.dart';
import 'asset_performance.dart';
import 'chart_point.dart';
import 'market_overview_item.dart';
import 'money_change.dart';
import 'recent_activity.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.portfolioValue,
    required this.todaysProfit,
    required this.overallProfit,
    required this.topGainers,
    required this.topLosers,
    required this.allocation,
    required this.recentActivity,
    required this.marketOverview,
    required this.portfolioChart,
    required this.updatedAt,
  });

  final double portfolioValue;
  final MoneyChange todaysProfit;
  final MoneyChange overallProfit;
  final List<AssetPerformance> topGainers;
  final List<AssetPerformance> topLosers;
  final List<AllocationSlice> allocation;
  final List<RecentActivity> recentActivity;
  final List<MarketOverviewItem> marketOverview;
  final List<ChartPoint> portfolioChart;
  final DateTime updatedAt;

  factory DashboardSummary.empty() {
    final now = DateTime.now();
    return DashboardSummary(
      portfolioValue: 0,
      todaysProfit: const MoneyChange(amount: 0, percent: 0),
      overallProfit: const MoneyChange(amount: 0, percent: 0),
      topGainers: const [],
      topLosers: const [],
      allocation: const [],
      recentActivity: const [],
      marketOverview: const [],
      portfolioChart: List.generate(
        7,
        (index) => ChartPoint(
          timestamp: now.subtract(Duration(days: 6 - index)),
          value: 0,
        ),
      ),
      updatedAt: now,
    );
  }
}
