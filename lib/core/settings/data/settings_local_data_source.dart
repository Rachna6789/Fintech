import 'package:hive_flutter/hive_flutter.dart';

import '../../services/hive_service.dart';
import '../../storage/hive_boxes.dart';
import '../entities/app_settings.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._hiveService);

  static const _settingsKey = 'app_settings';

  final HiveService _hiveService;

  Future<AppSettings> readSettings() async {
    final box = await _box();
    final value = box.get(_settingsKey);
    if (value is! Map) return const AppSettings.defaults();
    return _fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> saveSettings(AppSettings settings) async {
    final box = await _box();
    await box.put(_settingsKey, _toJson(settings));
  }

  Future<void> patchSettings({
    String? baseCurrency,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    List<String>? marketSymbols,
  }) async {
    final current = await readSettings();
    await saveSettings(
      current.copyWith(
        baseCurrency: baseCurrency,
        isDarkMode: isDarkMode,
        notificationsEnabled: notificationsEnabled,
        biometricEnabled: biometricEnabled,
        marketSymbols: marketSymbols,
        updatedAt: DateTime.now(),
      ),
    );
  }

  AppSettings _fromJson(Map<String, dynamic> json) {
    final symbols = json['marketSymbols'];
    return AppSettings(
      baseCurrency: json['baseCurrency'] as String? ?? 'USD',
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      marketSymbols: symbols is List
          ? symbols.whereType<String>().toList(growable: false)
          : const AppSettings.defaults().marketSymbols,
      updatedAt: _date(json['updatedAt']),
    );
  }

  Map<String, dynamic> _toJson(AppSettings settings) {
    return {
      'baseCurrency': settings.baseCurrency,
      'isDarkMode': settings.isDarkMode,
      'notificationsEnabled': settings.notificationsEnabled,
      'biometricEnabled': settings.biometricEnabled,
      'marketSymbols': settings.marketSymbols,
      'updatedAt': (settings.updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  DateTime? _date(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Future<Box<dynamic>> _box() async {
    if (!Hive.isBoxOpen(HiveBoxes.settings)) {
      return _hiveService.openBox<dynamic>(HiveBoxes.settings);
    }
    return _hiveService.box<dynamic>(HiveBoxes.settings);
  }
}
