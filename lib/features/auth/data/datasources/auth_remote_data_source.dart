import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/profile_setup_data.dart';
import '../models/auth_user_model.dart';
import '../models/user_profile_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  Stream<AuthUserModel?> watchAuthState() {
    return _authService.authStateChanges.asyncMap((session) async {
      final user = _authService.currentUser;
      if (session == null || user == null) return null;
      return _buildUser(user);
    });
  }

  Future<AuthUserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    return _buildUser(user);
  }

  Future<AuthUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _buildUser(_requireCurrentUser());
  }

  Future<AuthUserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    final user = _requireCurrentUser();
    await _createProfileIfMissing(
      user: user,
      displayName: displayName,
      isProfileComplete: false,
    );
    return _buildUser(user);
  }

  Future<AuthUserModel> signInWithGoogle() async {
    await _authService.signInWithGoogle();
    final user = _requireCurrentUser();
    await _createProfileIfMissing(
      user: user,
      displayName: user.displayName ?? 'FinTrack User',
      isProfileComplete: false,
    );
    return _buildUser(user);
  }

  Future<void> sendEmailVerification() {
    return _authService.sendEmailVerification();
  }

  Future<AuthUserModel?> reloadCurrentUser() async {
    await _authService.reloadCurrentUser();
    final user = _authService.currentUser;
    if (user == null) return null;
    return _buildUser(user);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<AuthUserModel> completeProfileSetup(ProfileSetupData data) async {
    final user = _requireCurrentUser();
    final profile = UserProfileModel(
      uid: user.uid,
      email: user.email,
      displayName: data.displayName.trim(),
      baseCurrency: data.baseCurrency,
      isProfileComplete: true,
      photoUrl: user.photoURL,
    );

    await user.updateDisplayName(profile.displayName);
    await _userDocument(user.uid)
        .set(profile.toJson(), SetOptions(merge: true));
    return _buildUser(user);
  }

  Future<void> signOut() => _authService.signOut();

  Future<AuthUserModel> _buildUser(User user) async {
    final snapshot = await _userDocument(user.uid).get();
    return AuthUserModel.fromFirebaseUser(user, profile: snapshot.data());
  }

  Future<void> _createProfileIfMissing({
    required User user,
    required String displayName,
    required bool isProfileComplete,
  }) async {
    final document = _userDocument(user.uid);
    final snapshot = await document.get();
    if (snapshot.exists) return;

    await document.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': displayName.trim(),
      'baseCurrency': 'USD',
      'isProfileComplete': isProfileComplete,
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) {
    return _firestoreService.collection(FirestoreCollections.users).doc(uid);
  }

  User _requireCurrentUser() {
    final user = _authService.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }
    return user;
  }
}
