import 'package:flutter/material.dart';

import '../../domain/entities/price_alert.dart';

class PriceAlertTile extends StatelessWidget {
  const PriceAlertTile({
    super.key,
    required this.alert,
    required this.onToggle,
    required this.onDelete,
  });

  final PriceAlert alert;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text('${alert.symbol} • ${alert.assetName}'),
        subtitle: Text(
          '${alert.condition.label} ${alert.targetPrice.toStringAsFixed(2)} • ${alert.isEnabled ? 'Enabled' : 'Disabled'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: alert.isEnabled, onChanged: onToggle),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete alert',
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: alert.isEnabled
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            alert.isEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: alert.isEnabled ? theme.colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}
