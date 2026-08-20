import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../providers/portfolio_providers.dart';
import '../widgets/portfolio_asset_tile.dart';
import '../widgets/portfolio_filter_bar.dart';
import '../widgets/portfolio_summary_card.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioControllerProvider);
    final controller = ref.read(portfolioControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            tooltip: 'Add asset',
            onPressed: () => context.go(RoutePaths.portfolioAdd),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: state.errorMessage != null
          ? AppErrorView(message: state.errorMessage!)
          : RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(portfolioControllerProvider),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PortfolioSummaryCard(
                    totalValue: state.totalValue,
                    totalProfitLoss: state.totalProfitLoss,
                  ),
                  const SizedBox(height: 16),
                  PortfolioFilterBar(
                    filters: state.filters,
                    onSearchChanged: controller.setSearchQuery,
                    onTypeChanged: controller.setTypeFilter,
                    onFavoritesChanged: controller.setFavoritesOnly,
                    onSortChanged: controller.setSort,
                  ),
                  const SizedBox(height: 16),
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.visibleAssets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: Text('No portfolio assets found.')),
                    )
                  else
                    for (final asset in state.visibleAssets)
                      PortfolioAssetTile(
                        asset: asset,
                        onTap: () => context.go(
                          RoutePaths.portfolioDetailPath(asset.id),
                        ),
                        onToggleFavorite: () =>
                            controller.toggleFavorite(asset),
                      ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RoutePaths.portfolioAdd),
        icon: const Icon(Icons.add),
        label: const Text('Add Asset'),
      ),
    );
  }
}
