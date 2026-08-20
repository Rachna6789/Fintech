class OfflineStatus {
  const OfflineStatus({
    required this.isOnline,
    required this.pendingSyncCount,
    required this.isSyncing,
    this.lastSyncedAt,
  });

  const OfflineStatus.initial()
      : isOnline = true,
        pendingSyncCount = 0,
        isSyncing = false,
        lastSyncedAt = null;

  final bool isOnline;
  final int pendingSyncCount;
  final bool isSyncing;
  final DateTime? lastSyncedAt;

  bool get hasPendingSync => pendingSyncCount > 0;

  OfflineStatus copyWith({
    bool? isOnline,
    int? pendingSyncCount,
    bool? isSyncing,
    DateTime? lastSyncedAt,
  }) {
    return OfflineStatus(
      isOnline: isOnline ?? this.isOnline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
