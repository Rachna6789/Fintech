import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../offline_providers.dart';
import '../offline_status.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(offlineStatusProvider);
    if (status.isOnline && !status.hasPendingSync) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final background = status.isOnline
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final foreground = status.isOnline
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;

    final message = _message(status);

    return Material(
      color: background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              status.isSyncing
                  ? Icons.sync
                  : status.isOnline
                      ? Icons.cloud_upload_outlined
                      : Icons.cloud_off_outlined,
              color: foreground,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foreground, fontSize: 13),
              ),
            ),
            if (status.isOnline && status.hasPendingSync)
              TextButton(
                onPressed: status.isSyncing
                    ? null
                    : () => ref.read(offlineStatusProvider.notifier).syncNow(),
                child: Text(status.isSyncing ? 'Syncing...' : 'Sync now'),
              ),
          ],
        ),
      ),
    );
  }

  String _message(OfflineStatus status) {
    if (status.isSyncing) {
      return 'Syncing offline changes...';
    }
    if (!status.isOnline) {
      final pending = status.pendingSyncCount;
      if (pending > 0) {
        return 'Offline mode. $pending change${pending == 1 ? '' : 's'} queued.';
      }
      return 'Offline mode. Showing cached data.';
    }
    return '${status.pendingSyncCount} change${status.pendingSyncCount == 1 ? '' : 's'} waiting to sync.';
  }
}
