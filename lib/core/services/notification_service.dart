import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../firebase_options.dart';
import '../constants/storage_keys.dart';
import '../router/app_router.dart';
import '../router/route_paths.dart';
import 'secure_storage_service.dart';

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    messaging: ref.watch(firebaseMessagingProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
});

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final plugin = FlutterLocalNotificationsPlugin();
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await plugin.initialize(settings: initSettings);
  await plugin.show(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: message.notification?.title ?? 'FinTrack',
    body: message.notification?.body ?? 'You have a new notification.',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'price_alerts',
        'Price Alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: message.data['route']?.toString() ?? RoutePaths.alerts,
  );
}

@pragma('vm:entry-point')
Future<void> notificationTapBackgroundHandler(NotificationResponse response) async {}

class NotificationService {
  NotificationService({
    required FirebaseMessaging messaging,
    required SecureStorageService secureStorageService,
  })  : _messaging = messaging,
        _secureStorageService = secureStorageService;

  final FirebaseMessaging _messaging;
  final SecureStorageService _secureStorageService;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _tokenSubscription;
  bool _initialMessageHandled = false;

  Future<void> initialize() async {
    await requestPermission();
    await _initializeLocalNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await syncTokenLocally();
    await subscribeToTopic('fintrack');

    _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(handleForegroundMessage);

    _openedAppSubscription?.cancel();
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    _tokenSubscription?.cancel();
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      await _secureStorageService.write(StorageKeys.fcmToken, token);
    });
  }

  Future<void> handlePendingInitialMessage() async {
    if (_initialMessageHandled) return;
    _initialMessageHandled = true;
    final initialMessage = await getInitialMessage();
    if (initialMessage != null) {
      await handleMessage(initialMessage);
    }
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<String?> syncTokenLocally() async {
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _secureStorageService.write(StorageKeys.fcmToken, token);
    }
    return token;
  }

  Future<void> subscribeToTopic(String topic) {
    return _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) {
    return _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'price_alerts',
          'Price Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'FinTrack';
    final body = message.notification?.body ?? 'You have a new notification.';
    await showLocalNotification(
      title: title,
      body: body,
      payload: _extractRoute(message),
    );
  }

  Future<void> handleMessage(RemoteMessage message) async {
    final payloadRoute = _extractRoute(message);
    final title = message.notification?.title ?? 'FinTrack';
    final body = message.notification?.body ?? 'You have a new notification.';
    await showLocalNotification(
      title: title,
      body: body,
      payload: payloadRoute,
    );
    _navigateToRoute(payloadRoute);
  }

  Stream<RemoteMessage> get foregroundMessages => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get openedAppMessages =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _navigateToRoute(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackgroundHandler,
    );
  }

  void _navigateToRoute(String? path) {
    final route = _normalizeRoute(path);
    if (route == null) return;
    final context = appNavigatorKey.currentContext;
    if (context != null) {
      context.go(route);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appNavigatorKey.currentContext?.go(route);
    });
  }

  String? _extractRoute(RemoteMessage message) {
    final route = message.data['route']?.toString() ?? message.data['path']?.toString();
    return route?.isNotEmpty == true ? route : null;
  }

  String? _normalizeRoute(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    return path.startsWith('/') ? path : '/$path';
  }
}
