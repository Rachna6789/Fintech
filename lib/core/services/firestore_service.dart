import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  return firestore;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.watch(firestoreProvider));
});

class FirestoreService {
  const FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) {
    return document(path).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(String path) {
    return document(path).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String path) {
    return collection(path).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String path) {
    return collection(path).snapshots();
  }

  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = true,
  }) {
    return document(path).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument(String path, Map<String, dynamic> data) {
    return document(path).update(data);
  }

  Future<void> deleteDocument(String path) {
    return document(path).delete();
  }

  WriteBatch batch() => _firestore.batch();

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) {
    return _firestore.runTransaction(updateFunction);
  }

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();
}
