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
import '../widgets/password_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to track your portfolio in real time.',
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
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordController,
              validator: Validators.password,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(RoutePaths.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ),
            AppButton(
              label: 'Sign in',
              isLoading: authState.isLoading,
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                controller.signInWithEmail(
                  _emailController.text,
                  _passwordController.text,
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed:
                  authState.isLoading ? null : controller.signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Continue with Google'),
            ),
            if (authState.isBiometricEnabled) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : controller.authenticateWithBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock with biometrics'),
              ),
            ],
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go(RoutePaths.register),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
