class AppSettings {
  const AppSettings({
    required this.baseCurrency,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.biometricEnabled,
    required this.marketSymbols,
    required this.updatedAt,
  });

  const AppSettings.defaults()
      : baseCurrency = 'USD',
        isDarkMode = false,
        notificationsEnabled = true,
        biometricEnabled = false,
        marketSymbols = const ['AAPL', 'MSFT', 'GOOGL', 'BTC-USD', 'ETH-USD'],
        updatedAt = null;

  final String baseCurrency;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final List<String> marketSymbols;
  final DateTime? updatedAt;

  AppSettings copyWith({
    String? baseCurrency,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    List<String>? marketSymbols,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      marketSymbols: marketSymbols ?? this.marketSymbols,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
