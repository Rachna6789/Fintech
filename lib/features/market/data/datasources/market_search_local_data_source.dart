import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/services/hive_service.dart';
import '../../../../core/storage/hive_boxes.dart';

class MarketSearchLocalDataSource {
  const MarketSearchLocalDataSource(this._hiveService);

  static const _recentSearchesKey = 'recent_searches';

  final HiveService _hiveService;

  Future<List<String>> readRecentSearches() async {
    final box = await _box();
    final value = box.get(_recentSearchesKey);
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  Future<void> saveRecentSearches(List<String> searches) async {
    final box = await _box();
    await box.put(_recentSearchesKey, searches);
  }

  Future<void> addSearch(String value) async {
    final normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) return;
    final searches = await readRecentSearches();
    final next = [
      normalized,
      ...searches.where((item) => item != normalized),
    ].take(10).toList();
    await saveRecentSearches(next);
  }

  Future<Box<dynamic>> _box() async {
    if (!Hive.isBoxOpen(HiveBoxes.recentSearches)) {
      return _hiveService.openBox<dynamic>(HiveBoxes.recentSearches);
    }
    return _hiveService.box<dynamic>(HiveBoxes.recentSearches);
  }
}
