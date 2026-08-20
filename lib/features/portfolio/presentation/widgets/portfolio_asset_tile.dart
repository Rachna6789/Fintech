import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/portfolio_asset.dart';

class PortfolioAssetTile extends StatelessWidget {
  const PortfolioAssetTile({
    super.key,
    required this.asset,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final PortfolioAsset asset;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'USD ');
    final color = asset.profitLoss >= 0
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(asset.symbol.characters.first)),
        title: Text(asset.symbol),
        subtitle: Text('${asset.name} - ${asset.type.label}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatter.format(asset.currentValue)),
                Text(
                  '${asset.profitLossPercent.toStringAsFixed(2)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            IconButton(
              tooltip: asset.isFavorite ? 'Remove favorite' : 'Add favorite',
              onPressed: onToggleFavorite,
              icon: Icon(asset.isFavorite ? Icons.star : Icons.star_border),
            ),
          ],
        ),
      ),
    );
  }
}
