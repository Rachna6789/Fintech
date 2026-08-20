enum MarketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error;

  String get label => switch (this) {
        MarketConnectionStatus.disconnected => 'Disconnected',
        MarketConnectionStatus.connecting => 'Connecting',
        MarketConnectionStatus.connected => 'Live',
        MarketConnectionStatus.reconnecting => 'Reconnecting',
        MarketConnectionStatus.error => 'Connection error',
      };
}
