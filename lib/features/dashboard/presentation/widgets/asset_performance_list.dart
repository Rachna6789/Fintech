import 'package:flutter/material.dart';

import '../../domain/entities/asset_performance.dart';

class AssetPerformanceList extends StatelessWidget {
  const AssetPerformanceList({
    super.key,
    required this.assets,
    required this.formatCurrency,
  });

  final List<AssetPerformance> assets;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) return const _EmptyList(label: 'No assets yet.');

    return Column(
      children: [
        for (final asset in assets)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text(asset.symbol.characters.first)),
            title: Text(asset.symbol),
            subtitle: Text(asset.name),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatCurrency(asset.price)),
                Text(
                  '${asset.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: asset.isPositive
                        ? Colors.green.shade700
                        : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: Text(label)),
    );
  }
}
