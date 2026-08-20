import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../providers/portfolio_providers.dart';
import '../widgets/portfolio_asset_form.dart';

class EditPortfolioAssetScreen extends ConsumerWidget {
  const EditPortfolioAssetScreen({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioControllerProvider);
    final controller = ref.read(portfolioControllerProvider.notifier);
    final asset = controller.assetById(assetId);

    if (asset == null) {
      return const Scaffold(
        body: AppErrorView(message: 'Portfolio asset was not found.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Asset')),
      body: PortfolioAssetForm(
        initialAsset: asset,
        isLoading: state.isLoading,
        onSubmit: (input) async {
          final saved = await controller.updateAsset(assetId, input);
          if (saved && context.mounted) {
            context.go(RoutePaths.portfolioDetailPath(assetId));
          }
        },
      ),
    );
  }
}
