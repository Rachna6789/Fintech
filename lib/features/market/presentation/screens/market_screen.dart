import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../domain/entities/market_connection_status.dart';
import '../providers/market_providers.dart';
import '../widgets/market_card.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  late final TextEditingController _symbolsController;

  @override
  void initState() {
    super.initState();
    _symbolsController = TextEditingController(
      text: ref.read(marketControllerProvider).symbols.join(', '),
    );
  }

  @override
  void dispose() {
    _symbolsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketControllerProvider);
    final controller = ref.read(marketControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
        actions: [
          IconButton(
            tooltip: 'Reconnect live feed',
            onPressed: controller.reconnect,
            icon: const Icon(Icons.cable),
          ),
          IconButton(
            tooltip: 'Refresh prices',
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.errorMessage != null && state.quotes.isEmpty
          ? AppErrorView(
              message: state.errorMessage!,
              onRetry: controller.refresh,
            )
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ConnectionBanner(status: state.connectionStatus),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _InlineError(message: state.errorMessage!),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _symbolsController,
                    decoration: InputDecoration(
                      labelText: 'Symbols',
                      helperText: 'Comma separated, for example AAPL, BTC-USD',
                      suffixIcon: IconButton(
                        tooltip: 'Apply symbols',
                        onPressed: () {
                          controller.updateSymbols(
                            _symbolsController.text.split(','),
                          );
                        },
                        icon: const Icon(Icons.check),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      controller
                          .updateSymbols(_symbolsController.text.split(','));
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isRefreshing
                        ? 'Refreshing prices...'
                        : 'Updated ${DateFormat('MMM d, h:mm a').format(DateTime.now())}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (state.isLoading && state.quotes.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (state.quotes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: Text('No market quotes available.')),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 900
                            ? 3
                            : constraints.maxWidth >= 620
                                ? 2
                                : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.quotes.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.55,
                          ),
                          itemBuilder: (context, index) {
                            return MarketCard(quote: state.quotes[index]);
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.status});

  final MarketConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLive = status == MarketConnectionStatus.connected;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isLive ? Colors.green.shade50 : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isLive ? Icons.wifi : Icons.wifi_off,
            color:
                isLive ? Colors.green.shade700 : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text('Live feed: ${status.label}'),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}
