import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_button.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final email = authState.user?.email ?? 'your email';

    return AuthScaffold(
      title: 'Verify your email',
      subtitle: 'We sent a verification link to $email.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthMessageBanner(
            errorMessage: authState.errorMessage,
            successMessage: authState.successMessage,
          ),
          AppButton(
            label: 'I have verified',
            isLoading: authState.isLoading,
            onPressed: controller.refreshEmailVerification,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed:
                authState.isLoading ? null : controller.resendEmailVerification,
            child: const Text('Resend verification email'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: authState.isLoading ? null : controller.signOut,
            child: const Text('Use another account'),
          ),
        ],
      ),
    );
  }
}
