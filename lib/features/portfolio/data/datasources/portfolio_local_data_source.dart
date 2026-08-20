import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/services/hive_service.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../domain/entities/portfolio_asset.dart';
import '../models/portfolio_asset_model.dart';

class PortfolioLocalDataSource {
  const PortfolioLocalDataSource(this._hiveService);

  static const _assetsKey = 'assets';

  final HiveService _hiveService;

  Future<List<PortfolioAsset>> readAssets() async {
    final box = await _box();
    final value = box.get(_assetsKey);
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((item) => PortfolioAssetModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Stream<List<PortfolioAsset>> watchAssets() async* {
    final box = await _box();
    yield await readAssets();
    await for (final _ in box.watch(key: _assetsKey)) {
      yield await readAssets();
    }
  }

  Future<void> saveAssets(List<PortfolioAsset> assets) async {
    final box = await _box();
    final payload = assets
        .map((asset) => PortfolioAssetModel.fromEntity(asset).toJson())
        .toList(growable: false);
    await box.put(_assetsKey, payload);
  }

  Future<void> upsertAsset(PortfolioAsset asset) async {
    final assets = await readAssets();
    final index = assets.indexWhere((item) => item.id == asset.id);
    final next = [...assets];
    if (index == -1) {
      next.insert(0, asset);
    } else {
      next[index] = asset;
    }
    await saveAssets(next);
  }

  Future<void> removeAsset(String id) async {
    final assets = await readAssets();
    await saveAssets(assets.where((asset) => asset.id != id).toList());
  }

  Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }

  Future<Box<dynamic>> _box() async {
    if (!Hive.isBoxOpen(HiveBoxes.portfolio)) {
      return _hiveService.openBox<dynamic>(HiveBoxes.portfolio);
    }
    return _hiveService.box<dynamic>(HiveBoxes.portfolio);
  }
}
