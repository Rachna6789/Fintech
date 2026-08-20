import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.uid,
    required super.email,
    required super.isEmailVerified,
    required super.isAnonymous,
    required super.providerIds,
    required super.isProfileComplete,
    super.displayName,
    super.baseCurrency,
    super.photoUrl,
  });

  factory AuthUserModel.fromFirebaseUser(
    User user, {
    Map<String, dynamic>? profile,
  }) {
    return AuthUserModel(
      uid: user.uid,
      email: user.email,
      isEmailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
      providerIds: user.providerData.map((info) => info.providerId).toList(),
      isProfileComplete: profile?['isProfileComplete'] as bool? ?? false,
      displayName: profile?['displayName'] as String? ?? user.displayName,
      baseCurrency: profile?['baseCurrency'] as String?,
      photoUrl: profile?['photoUrl'] as String? ?? user.photoURL,
    );
  }
}
