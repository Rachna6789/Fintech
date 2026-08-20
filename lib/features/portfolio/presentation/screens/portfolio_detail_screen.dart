import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../providers/portfolio_providers.dart';

class PortfolioDetailScreen extends ConsumerWidget {
  const PortfolioDetailScreen({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(portfolioControllerProvider.notifier);
    final asset = controller.assetById(assetId);
    final formatter = NumberFormat.currency(symbol: 'USD ');

    if (asset == null) {
      return const Scaffold(
        body: AppErrorView(message: 'Portfolio asset was not found.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.symbol),
        actions: [
          IconButton(
            tooltip: asset.isFavorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () => controller.toggleFavorite(asset),
            icon: Icon(asset.isFavorite ? Icons.star : Icons.star_border),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: () => context.go(RoutePaths.portfolioEditPath(asset.id)),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete asset?'),
                  content: Text('Remove ${asset.symbol} from your portfolio?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;
              final deleted = await controller.deleteAsset(asset.id);
              if (deleted && context.mounted) context.go(RoutePaths.portfolio);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(asset.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(asset.type.label),
          const SizedBox(height: 24),
          _DetailRow(label: 'Quantity', value: asset.quantity.toString()),
          _DetailRow(
            label: 'Average buy price',
            value: formatter.format(asset.averageBuyPrice),
          ),
          _DetailRow(
            label: 'Current price',
            value: formatter.format(asset.currentPrice),
          ),
          _DetailRow(
            label: 'Invested value',
            value: formatter.format(asset.investedValue),
          ),
          _DetailRow(
            label: 'Current value',
            value: formatter.format(asset.currentValue),
          ),
          _DetailRow(
            label: 'Profit/Loss',
            value:
                '${formatter.format(asset.profitLoss)} (${asset.profitLossPercent.toStringAsFixed(2)}%)',
          ),
          if (asset.notes != null && asset.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Notes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(asset.notes!),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
