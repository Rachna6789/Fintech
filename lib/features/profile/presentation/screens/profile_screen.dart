import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileControllerProvider.notifier).loadProfile());
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    final profile = state.profile;
    if (profile != null) {
      _displayNameController.text = profile.displayName;
      _currencyController.text = profile.baseCurrency;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.go(RoutePaths.dashboard),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(profile?.displayName ?? 'FinTrack User'),
                          subtitle: Text(profile?.email ?? 'No email available'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(labelText: 'Display name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _currencyController,
                          decoration: const InputDecoration(labelText: 'Base currency'),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () async {
                            await controller.updateProfile(
                              displayName: _displayNameController.text.trim(),
                              baseCurrency: _currencyController.text.trim().toUpperCase(),
                            );
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save profile'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: profile?.isDarkMode ?? false,
                        onChanged: (value) async {
                          await controller.updateProfile(isDarkMode: value);
                        },
                        title: const Text('Dark mode'),
                        subtitle: const Text('Use the dark visual theme.'),
                      ),
                      SwitchListTile(
                        value: profile?.notificationsEnabled ?? true,
                        onChanged: (value) async {
                          await controller.updateProfile(notificationsEnabled: value);
                        },
                        title: const Text('Notifications'),
                        subtitle: const Text('Receive price and market alerts.'),
                      ),
                      SwitchListTile(
                        value: profile?.biometricEnabled ?? false,
                        onChanged: (value) async {
                          await controller.updateProfile(biometricEnabled: value);
                        },
                        title: const Text('Biometric login'),
                        subtitle: const Text('Use device biometrics to sign in.'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    await controller.deleteAccount();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete account'),
                ),
              ],
            ),
    );
  }
}
