import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.baseCurrency,
    required this.isProfileComplete,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String displayName;
  final String baseCurrency;
  final bool isProfileComplete;
  final String? photoUrl;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'baseCurrency': baseCurrency,
      'isProfileComplete': isProfileComplete,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
