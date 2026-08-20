import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: authController.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Portfolio dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: authState.isBiometricEnabled,
            onChanged: authController.setBiometricEnabled,
            title: const Text('Biometric login'),
            subtitle: const Text('Use device biometrics for persistent login.'),
          ),
        ],
      ),
    );
  }
}
