import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/portfolio_asset.dart';
import '../../domain/entities/portfolio_asset_input.dart';
import '../models/portfolio_asset_model.dart';

class PortfolioRemoteDataSource {
  const PortfolioRemoteDataSource({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  Stream<List<PortfolioAsset>> watchAssets() {
    return _collection().orderBy('updatedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map(PortfolioAssetModel.fromDocument)
              .toList(growable: false),
        );
  }

  Future<List<PortfolioAsset>> getAssets() async {
    final snapshot =
        await _collection().orderBy('updatedAt', descending: true).get();
    return snapshot.docs
        .map(PortfolioAssetModel.fromDocument)
        .toList(growable: false);
  }

  Future<PortfolioAsset> getAsset(String id) async {
    final snapshot = await _collection().doc(id).get();
    if (!snapshot.exists) {
      throw const CacheException('Portfolio asset was not found.');
    }
    return PortfolioAssetModel.fromDocument(snapshot);
  }

  Future<void> addAsset(PortfolioAssetInput input) {
    return _collection().add(PortfolioAssetModel.createJson(input));
  }

  Future<void> updateAsset(String id, PortfolioAssetInput input) {
    return _collection().doc(id).update(PortfolioAssetModel.updateJson(input));
  }

  Future<void> deleteAsset(String id) {
    return _collection().doc(id).delete();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) {
    return _collection().doc(id).update({
      'isFavorite': isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  CollectionReference<Map<String, dynamic>> _collection() {
    final user = _authService.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    return _firestoreService
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .collection('portfolio_assets');
  }
}
