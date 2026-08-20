import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../storage/hive_boxes.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  HiveService();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    for (final boxName in HiveBoxes.all) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<dynamic>(boxName);
      }
    }
    _isInitialized = true;
  }

  Future<Box<T>> openBox<T>(String name) {
    return Hive.openBox<T>(name);
  }

  Box<T> box<T>(String name) {
    return Hive.box<T>(name);
  }

  Future<void> close() {
    return Hive.close();
  }
}
