import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(authControllerProvider).user?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: 'Complete profile',
      subtitle: 'Choose the basics for portfolio calculations.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthMessageBanner(errorMessage: authState.errorMessage),
            AppTextField(
              controller: _nameController,
              label: 'Display name',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) =>
                  Validators.required(value, fieldName: 'Display name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(
                labelText: 'Base currency',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                DropdownMenuItem(value: 'INR', child: Text('INR')),
              ],
              onChanged: (value) => setState(() => _currency = value ?? 'USD'),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Finish setup',
              isLoading: authState.isLoading,
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                ref.read(authControllerProvider.notifier).completeProfileSetup(
                      displayName: _nameController.text,
                      baseCurrency: _currency,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
