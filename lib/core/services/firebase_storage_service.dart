import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService(ref.watch(firebaseStorageProvider));
});

class FirebaseStorageService {
  const FirebaseStorageService(this._storage);

  final FirebaseStorage _storage;

  Reference ref(String path) => _storage.ref(path);

  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    SettableMetadata? metadata,
  }) async {
    final task = await ref(path).putData(bytes, metadata);
    return task.ref.getDownloadURL();
  }

  Future<String> uploadFile({
    required String path,
    required File file,
    SettableMetadata? metadata,
  }) async {
    final task = await ref(path).putFile(file, metadata);
    return task.ref.getDownloadURL();
  }

  Future<String> downloadUrl(String path) {
    return ref(path).getDownloadURL();
  }

  Future<void> delete(String path) {
    return ref(path).delete();
  }
}
