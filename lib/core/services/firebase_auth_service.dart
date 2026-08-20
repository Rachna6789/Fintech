import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_exception.dart';
import '../models/auth_session.dart';
import 'google_sign_in_service.dart';
import 'secure_storage_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(
    auth: ref.watch(firebaseAuthProvider),
    googleSignInService: ref.watch(googleSignInServiceProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
});

final authStateChangesProvider = StreamProvider<AuthSession?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

class FirebaseAuthService {
  const FirebaseAuthService({
    required FirebaseAuth auth,
    required GoogleSignInService googleSignInService,
    required SecureStorageService secureStorageService,
  })  : _auth = auth,
        _googleSignInService = googleSignInService,
        _secureStorageService = secureStorageService;

  final FirebaseAuth _auth;
  final GoogleSignInService _googleSignInService;
  final SecureStorageService _secureStorageService;

  User? get currentUser => _auth.currentUser;

  AuthSession? get currentSession {
    final user = _auth.currentUser;
    return user == null ? null : AuthSession.fromFirebaseUser(user);
  }

  Stream<AuthSession?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      await _persistSecureSession(user);
      return AuthSession.fromFirebaseUser(user);
    });
  }

  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _completeSignIn(credential.user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(
        error.message ?? 'Unable to sign in.',
        code: error.code,
        cause: error,
      );
    }
  }

  Future<AuthSession> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }

      await credential.user?.sendEmailVerification();
      return _completeSignIn(credential.user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(
        error.message ?? 'Unable to create account.',
        code: error.code,
        cause: error,
      );
    }
  }

  Future<AuthSession> signInWithGoogle() async {
    try {
      final credential = await _googleSignInService.credential();
      final userCredential = await _auth.signInWithCredential(credential);
      return _completeSignIn(userCredential.user);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw AuthException(
        error.message ?? 'Unable to sign in with Google.',
        code: error.code,
        cause: error,
      );
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }
    if (user.emailVerified) return;

    await user.sendEmailVerification();
  }

  Future<void> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.reload();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(
        error.message ?? 'Unable to send password reset email.',
        code: error.code,
        cause: error,
      );
    }
  }

  Future<String> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    final token = await user.getIdToken(forceRefresh);
    if (token == null || token.isEmpty) {
      throw const AuthException('Unable to read Firebase ID token.');
    }

    await _secureStorageService.saveAuthToken(token);
    return token;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignInService.signOut(),
      _secureStorageService.clearAuthSession(),
    ]);
  }

  Future<AuthSession> _completeSignIn(User? user) async {
    if (user == null) {
      throw const AuthException('Authentication completed without a user.');
    }

    await _persistSecureSession(user);
    return AuthSession.fromFirebaseUser(user);
  }

  Future<void> _persistSecureSession(User user) async {
    final token = await user.getIdToken();
    await Future.wait([
      if (token != null && token.isNotEmpty)
        _secureStorageService.saveAuthToken(token),
      _secureStorageService.saveUserId(user.uid),
    ]);
  }
}
