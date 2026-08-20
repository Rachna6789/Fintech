// ignore_for_file: unused_import

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config_provider.dart';
import '../services/firebase_auth_service.dart';
import '../services/secure_storage_service.dart';
import 'dio_client.dart';
import 'socket_service.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    config: ref.watch(envConfigProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
    tokenRefreshHandler: () async {
      try {
        final auth = ref.read(firebaseAuthServiceProvider);
        return await auth.getIdToken(forceRefresh: true);
      } catch (_) {
        return null;
      }
    },
  );
});

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(
    config: ref.watch(envConfigProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
    heartbeatInterval: const Duration(seconds: 20),
    maxReconnectAttempts: 6,
  );
});
