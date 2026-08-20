import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../errors/app_exception.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(scopes: const ['email', 'profile']);
});

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService(ref.watch(googleSignInProvider));
});

class GoogleSignInService {
  const GoogleSignInService(this._googleSignIn);

  final GoogleSignIn _googleSignIn;

  Future<OAuthCredential> credential() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthException('Google sign in was cancelled.');
      }

      final authentication = await account.authentication;
      final accessToken = authentication.accessToken;
      final idToken = authentication.idToken;

      if (accessToken == null || idToken == null) {
        throw const AuthException(
          'Google sign in did not return valid tokens.',
        );
      }

      return GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException(
        'Google sign in failed.',
        code: 'google-sign-in-failed',
        cause: error,
      );
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
