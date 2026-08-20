import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/hive_service.dart';
import '../data/settings_local_data_source.dart';
import '../entities/app_settings.dart';

final settingsLocalDataSourceProvider =
    Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSource(ref.watch(hiveServiceProvider));
});

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _load();
    return const AppSettings.defaults();
  }

  Future<void> _load() async {
    final settings =
        await ref.read(settingsLocalDataSourceProvider).readSettings();
    state = settings;
  }

  Future<void> patch({
    String? baseCurrency,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    List<String>? marketSymbols,
  }) async {
    await ref.read(settingsLocalDataSourceProvider).patchSettings(
          baseCurrency: baseCurrency,
          isDarkMode: isDarkMode,
          notificationsEnabled: notificationsEnabled,
          biometricEnabled: biometricEnabled,
          marketSymbols: marketSymbols,
        );
    state = await ref.read(settingsLocalDataSourceProvider).readSettings();
  }
}
