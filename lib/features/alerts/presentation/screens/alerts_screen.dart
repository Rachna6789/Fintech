import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../providers/alerts_providers.dart';
import '../widgets/create_alert_dialog.dart';
import '../widgets/price_alert_tile.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alertsControllerProvider);
    final controller = ref.read(alertsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
        actions: [
          IconButton(
            tooltip: 'Create alert',
            onPressed: () async {
              await showDialog<bool>(
                context: context,
                builder: (context) => CreateAlertDialog(
                  onSubmit: controller.createAlert,
                ),
              );
            },
            icon: const Icon(Icons.add_alert_outlined),
          ),
        ],
      ),
      body: state.errorMessage != null
          ? AppErrorView(message: state.errorMessage!)
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(alertsControllerProvider),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (state.alerts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text('No price alerts yet. Create one to get started.'),
                            ),
                          )
                        else
                          for (final alert in state.alerts)
                            PriceAlertTile(
                              alert: alert,
                              onToggle: (enabled) async {
                                await controller.toggleAlert(alert.id, enabled);
                              },
                              onDelete: () async {
                                await controller.deleteAlert(alert.id);
                              },
                            ),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog<bool>(
            context: context,
            builder: (context) => CreateAlertDialog(
              onSubmit: controller.createAlert,
            ),
          );
        },
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Create Alert'),
      ),
    );
  }
}
