import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
    required FirebaseStorageService storageService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _storageService = storageService;

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final FirebaseStorageService _storageService;

  Stream<ProfileModel?> watchProfile() {
    final user = _requireUser();
    return _userDocument(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ProfileModel.fromMap(user.uid, snapshot.data() ?? const {});
    });
  }

  Future<ProfileModel?> getProfile() async {
    final user = _requireUser();
    final snapshot = await _userDocument(user.uid).get();
    if (!snapshot.exists) return null;
    return ProfileModel.fromMap(user.uid, snapshot.data() ?? const {});
  }

  Future<ProfileModel> updateProfile({
    String? displayName,
    String? baseCurrency,
    String? photoUrl,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) async {
    final user = _requireUser();
    final data = <String, dynamic>{};
    if (displayName != null) data['displayName'] = displayName.trim();
    if (baseCurrency != null) data['baseCurrency'] = baseCurrency;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (isDarkMode != null) data['isDarkMode'] = isDarkMode;
    if (notificationsEnabled != null) data['notificationsEnabled'] = notificationsEnabled;
    if (biometricEnabled != null) data['biometricEnabled'] = biometricEnabled;
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _userDocument(user.uid).set(data, SetOptions(merge: true));
    return (await getProfile())!;
  }

  Future<String> uploadProfilePicture(String path, dynamic file) async {
    final user = _requireUser();
    final remotePath = 'users/${user.uid}/profile/$path';
    return _storageService.uploadFile(path: remotePath, file: file);
  }

  Future<void> deleteAccount() async {
    final user = _requireUser();
    await _userDocument(user.uid).delete();
    await user.delete();
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) {
    return _firestoreService.collection(FirestoreCollections.users).doc(uid);
  }

  User _requireUser() {
    final user = _authService.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }
    return user;
  }
}
