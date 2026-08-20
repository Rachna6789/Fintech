import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/email_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'Enter your email and we will send a secure reset link.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthMessageBanner(
              errorMessage: authState.errorMessage,
              successMessage: authState.successMessage,
            ),
            EmailField(
              controller: _emailController,
              validator: Validators.email,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Send reset link',
              isLoading: authState.isLoading,
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                ref
                    .read(authControllerProvider.notifier)
                    .sendPasswordResetEmail(_emailController.text);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(RoutePaths.login),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
