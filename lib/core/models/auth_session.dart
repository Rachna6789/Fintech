import 'package:firebase_auth/firebase_auth.dart';

class AuthSession {
  const AuthSession({
    required this.uid,
    required this.email,
    required this.isEmailVerified,
    required this.isAnonymous,
    required this.providerIds,
  });

  final String uid;
  final String? email;
  final bool isEmailVerified;
  final bool isAnonymous;
  final List<String> providerIds;

  factory AuthSession.fromFirebaseUser(User user) {
    return AuthSession(
      uid: user.uid,
      email: user.email,
      isEmailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
      providerIds: user.providerData.map((info) => info.providerId).toList(),
    );
  }
}
