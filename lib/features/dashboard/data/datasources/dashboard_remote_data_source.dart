import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../models/dashboard_summary_model.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  Stream<DashboardSummary> watchDashboard() {
    final uid = _requireUid();
    return _dashboardDocument(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return DashboardSummary.empty();
      return DashboardSummaryModel.fromJson(data);
    });
  }

  Future<DashboardSummary> getDashboard() async {
    final uid = _requireUid();
    final snapshot = await _dashboardDocument(uid).get();
    final data = snapshot.data();
    if (data == null) return DashboardSummary.empty();
    return DashboardSummaryModel.fromJson(data);
  }

  DocumentReference<Map<String, dynamic>> _dashboardDocument(String uid) {
    return _firestoreService
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection('dashboard')
        .doc('summary');
  }

  String _requireUid() {
    final user = _authService.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }
    return user.uid;
  }
}
