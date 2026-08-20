import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';

class BiometricLoginScreen extends ConsumerWidget {
  const BiometricLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return AuthScaffold(
      title: 'Biometric login',
      subtitle:
          'Use your device biometrics to unlock your saved FinTrack session.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthMessageBanner(errorMessage: authState.errorMessage),
          AppButton(
            label: 'Unlock',
            icon: Icons.fingerprint,
            isLoading: authState.isLoading,
            onPressed: controller.authenticateWithBiometrics,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go(RoutePaths.login),
            child: const Text('Use password instead'),
          ),
        ],
      ),
    );
  }
}
