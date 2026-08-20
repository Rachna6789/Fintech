import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../providers/portfolio_providers.dart';
import '../widgets/portfolio_asset_form.dart';

class AddPortfolioAssetScreen extends ConsumerWidget {
  const AddPortfolioAssetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioControllerProvider);
    final controller = ref.read(portfolioControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Asset')),
      body: PortfolioAssetForm(
        isLoading: state.isLoading,
        onSubmit: (input) async {
          final saved = await controller.addAsset(input);
          if (saved && context.mounted) context.go(RoutePaths.portfolio);
        },
      ),
    );
  }
}
