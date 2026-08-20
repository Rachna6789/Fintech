class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.isEmailVerified,
    required this.isAnonymous,
    required this.providerIds,
    required this.isProfileComplete,
    this.displayName,
    this.baseCurrency,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final bool isEmailVerified;
  final bool isAnonymous;
  final List<String> providerIds;
  final bool isProfileComplete;
  final String? displayName;
  final String? baseCurrency;
  final String? photoUrl;

  AuthUser copyWith({
    String? uid,
    String? email,
    bool? isEmailVerified,
    bool? isAnonymous,
    List<String>? providerIds,
    bool? isProfileComplete,
    String? displayName,
    String? baseCurrency,
    String? photoUrl,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      providerIds: providerIds ?? this.providerIds,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      displayName: displayName ?? this.displayName,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
