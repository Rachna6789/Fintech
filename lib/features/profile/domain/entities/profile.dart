class Profile {
  const Profile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.baseCurrency,
    required this.photoUrl,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.biometricEnabled,
  });

  final String uid;
  final String? email;
  final String displayName;
  final String baseCurrency;
  final String? photoUrl;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool biometricEnabled;

  Profile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? baseCurrency,
    String? photoUrl,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) {
    return Profile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      photoUrl: photoUrl ?? this.photoUrl,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
