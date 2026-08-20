import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/entities/price_alert_input.dart';
import '../models/price_alert_model.dart';

class PriceAlertRemoteDataSource {
  const PriceAlertRemoteDataSource({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
    NotificationService? notificationService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _notificationService = notificationService;

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final NotificationService? _notificationService;

  Stream<List<PriceAlert>> watchAlerts() {
    return _collection()
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PriceAlertModel.fromDocument)
              .toList(growable: false),
        );
  }

  Future<void> createAlert(PriceAlertInput input) {
    final userId = _requireUserId();
    return _collection().add(
      PriceAlertModel.createJson(input: input, userId: userId),
    );
  }

  Future<void> deleteAlert(String id) {
    return _collection().doc(id).delete();
  }

  Future<void> setAlertEnabled(String id, bool enabled) {
    return _collection().doc(id).update({
      'isEnabled': enabled,
      if (enabled) 'hasTriggered': false,
      if (enabled) 'lastTriggeredAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> triggerAlert(String id, double currentPrice) async {
    final alertRef = _collection().doc(id);
    final snapshot = await alertRef.get();
    final data = snapshot.data();
    if (data == null) return;

    final alert = PriceAlertModel.fromDocument(snapshot);
    if (!alert.isEnabled || alert.hasTriggered) return;

    final shouldTrigger = alert.shouldTriggerAt(currentPrice);
    if (!shouldTrigger) return;

    await alertRef.update({
      'hasTriggered': true,
      'lastTriggeredAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notificationService?.showLocalNotification(
      title: data['notificationTitle']?.toString() ?? 'Price alert',
      body: data['notificationBody']?.toString() ?? 'Your price alert was triggered.',
    );

    await _recordNotification(alert, currentPrice);
  }

  Future<void> _recordNotification(PriceAlert alert, double currentPrice) async {
    final userId = _requireUserId();
    await _firestoreService.collection(FirestoreCollections.users).doc(userId).collection(FirestoreCollections.notifications).add({
      'title': 'Price alert triggered',
      'body': '${alert.symbol} reached ${currentPrice.toStringAsFixed(2)}',
      'alertId': alert.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  CollectionReference<Map<String, dynamic>> _collection() {
    final userId = _requireUserId();
    return _firestoreService
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.alerts);
  }

  String _requireUserId() {
    final user = _authService.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }
    return user.uid;
  }
}
