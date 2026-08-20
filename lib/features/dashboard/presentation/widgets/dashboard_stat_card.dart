import 'package:flutter/material.dart';

import '../../domain/entities/money_change.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
  });

  final String title;
  final String value;
  final MoneyChange? change;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changeValue = change;
    final isPositive = changeValue?.isPositive ?? true;
    final changeColor =
        isPositive ? Colors.green.shade700 : theme.colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: 10),
            Text(value, style: theme.textTheme.headlineSmall),
            if (changeValue != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 18,
                    color: changeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${changeValue.percent.toStringAsFixed(2)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
