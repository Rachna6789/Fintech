import 'package:flutter/material.dart';

class AuthMessageBanner extends StatelessWidget {
  const AuthMessageBanner({
    super.key,
    this.errorMessage,
    this.successMessage,
  });

  final String? errorMessage;
  final String? successMessage;

  @override
  Widget build(BuildContext context) {
    final message = errorMessage ?? successMessage;
    if (message == null) return const SizedBox.shrink();

    final isError = errorMessage != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer
            : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError
              ? colorScheme.onErrorContainer
              : colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
