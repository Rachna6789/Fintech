import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('FinTrack', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 32),
                  Text(title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
