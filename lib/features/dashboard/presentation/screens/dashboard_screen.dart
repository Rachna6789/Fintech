import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/allocation_chart.dart';
import '../widgets/asset_performance_list.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/market_overview_grid.dart';
import '../widgets/portfolio_line_chart.dart';
import '../widgets/recent_activity_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardSummaryProvider);
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final formatter = NumberFormat.currency(
      symbol: '${authState.user?.baseCurrency ?? 'USD'} ',
      decimalDigits: 2,
    );

    String money(double value) => formatter.format(value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack'),
        actions: [
          IconButton(
            tooltip: 'Portfolio',
            onPressed: () => context.go(RoutePaths.portfolio),
            icon: const Icon(Icons.account_balance_wallet_outlined),
          ),
          IconButton(
            tooltip: 'Markets',
            onPressed: () => context.go(RoutePaths.market),
            icon: const Icon(Icons.show_chart),
          ),
          IconButton(
            tooltip: 'Alerts',
            onPressed: () => context.go(RoutePaths.alerts),
            icon: const Icon(Icons.notifications_active_outlined),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.go(RoutePaths.settings),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: authController.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
        data: (summary) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Updated ${DateFormat('MMM d, h:mm a').format(summary.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 3 : 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 2.2 : 2.8,
                      children: [
                        DashboardStatCard(
                          title: 'Portfolio Value',
                          value: money(summary.portfolioValue),
                        ),
                        DashboardStatCard(
                          title: "Today's Profit",
                          value: money(summary.todaysProfit.amount),
                          change: summary.todaysProfit,
                        ),
                        DashboardStatCard(
                          title: 'Overall Profit',
                          value: money(summary.overallProfit.amount),
                          change: summary.overallProfit,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                DashboardSection(
                  title: 'Portfolio Value',
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PortfolioLineChart(points: summary.portfolioChart),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    final children = [
                      DashboardSection(
                        title: 'Top Gainers',
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: AssetPerformanceList(
                              assets: summary.topGainers,
                              formatCurrency: money,
                            ),
                          ),
                        ),
                      ),
                      DashboardSection(
                        title: 'Top Losers',
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: AssetPerformanceList(
                              assets: summary.topLosers,
                              formatCurrency: money,
                            ),
                          ),
                        ),
                      ),
                    ];

                    if (!isWide) {
                      return Column(
                        children: [
                          children.first,
                          const SizedBox(height: 24),
                          children.last,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: children.first),
                        const SizedBox(width: 16),
                        Expanded(child: children.last),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                DashboardSection(
                  title: 'Portfolio Allocation',
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AllocationChart(
                        allocation: summary.allocation,
                        formatCurrency: money,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                DashboardSection(
                  title: 'Market Overview',
                  child: MarketOverviewGrid(items: summary.marketOverview),
                ),
                const SizedBox(height: 24),
                DashboardSection(
                  title: 'Recent Activity',
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: RecentActivityList(
                        activities: summary.recentActivity,
                        formatCurrency: money,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  value: authState.isBiometricEnabled,
                  onChanged: authController.setBiometricEnabled,
                  title: const Text('Biometric login'),
                  subtitle:
                      const Text('Use device biometrics for persistent login.'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
