import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({
    super.key,
    required this.totalValue,
    required this.totalProfitLoss,
  });

  final double totalValue;
  final double totalProfitLoss;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'USD ');
    final isPositive = totalProfitLoss >= 0;
    final color = isPositive
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Portfolio Value',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(totalValue),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('P/L', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(
                  formatter.format(totalProfitLoss),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
