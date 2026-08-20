import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Set up secure access to your FinTrack portfolio.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthMessageBanner(errorMessage: authState.errorMessage),
            AppTextField(
              controller: _nameController,
              label: 'Full name',
              prefixIcon: const Icon(Icons.person_outline),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.required(value, fieldName: 'Full name'),
            ),
            const SizedBox(height: 16),
            EmailField(
              controller: _emailController,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordController,
              validator: Validators.password,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Create account',
              isLoading: authState.isLoading,
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                controller.registerWithEmail(
                  email: _emailController.text,
                  password: _passwordController.text,
                  displayName: _nameController.text,
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(RoutePaths.login),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
