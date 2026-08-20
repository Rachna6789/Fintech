import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/market_quote.dart';

class MarketCard extends StatelessWidget {
  const MarketCard({
    super.key,
    required this.quote,
  });

  final MarketQuote quote;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'USD ');
    final color = quote.isPositive
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.symbol,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quote.name.isEmpty ? quote.type.label : quote.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(quote.type.label)),
              ],
            ),
            const Spacer(),
            Text(
              formatter.format(quote.price),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  quote.isPositive ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${formatter.format(quote.changeAmount)} (${quote.changePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
