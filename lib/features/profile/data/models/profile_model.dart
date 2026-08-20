import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.baseCurrency,
    required super.photoUrl,
    required super.isDarkMode,
    required super.notificationsEnabled,
    required super.biometricEnabled,
  });

  factory ProfileModel.fromMap(String uid, Map<String, dynamic> data) {
    return ProfileModel(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String? ?? 'FinTrack User',
      baseCurrency: data['baseCurrency'] as String? ?? 'USD',
      photoUrl: data['photoUrl'] as String?,
      isDarkMode: data['isDarkMode'] as bool? ?? false,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'baseCurrency': baseCurrency,
      'photoUrl': photoUrl,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
