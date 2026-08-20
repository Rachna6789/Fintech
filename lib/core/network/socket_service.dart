import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/env_config.dart';
import '../services/secure_storage_service.dart';

enum SocketConnectionStatus { disconnected, connecting, connected, reconnecting }

typedef SocketEventHandler = void Function(dynamic data);

class SocketService {
  SocketService({
    required EnvConfig config,
    required SecureStorageService secureStorageService,
    Duration heartbeatInterval = const Duration(seconds: 20),
    int maxReconnectAttempts = 5,
  })  : _config = config,
        _secureStorageService = secureStorageService,
        _heartbeatInterval = heartbeatInterval,
        _maxReconnectAttempts = maxReconnectAttempts {
    _statusController = StreamController<SocketConnectionStatus>.broadcast();
    _eventControllers = <String, StreamController<dynamic>>{};
  }

  final EnvConfig _config;
  final SecureStorageService _secureStorageService;
  final Duration _heartbeatInterval;
  final int _maxReconnectAttempts;

  io.Socket? _socket;
  late final StreamController<SocketConnectionStatus> _statusController;
  late final Map<String, StreamController<dynamic>> _eventControllers;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;

  SocketConnectionStatus get status => _socket == null
      ? SocketConnectionStatus.disconnected
      : (_socket!.connected
          ? SocketConnectionStatus.connected
          : SocketConnectionStatus.connecting);

  Stream<SocketConnectionStatus> get onStatusChanged => _statusController.stream;

  Future<void> connect({bool force = false}) async {
    if (_socket != null && _socket!.connected && !force) return;

    _statusController.add(SocketConnectionStatus.connecting);

    final token = await _secureStorageService.readAuthToken();

    _socket?.dispose();

    _socket = io.io(
      _config.socketBaseUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': _maxReconnectAttempts,
        'reconnectionDelay': 1000,
        'auth': token != null ? {'token': token} : null,
      },
    );

    _attachNativeHandlers();
    _socket!.connect();
  }

  void _attachNativeHandlers() {
    if (_socket == null) return;

    _socket!.on('connect', (_) {
      _reconnectAttempts = 0;
      _statusController.add(SocketConnectionStatus.connected);
      _startHeartbeat();
    });

    _socket!.on('disconnect', (reason) {
      _statusController.add(SocketConnectionStatus.disconnected);
      _stopHeartbeat();
    });

    _socket!.on('connect_error', (error) {
      _statusController.add(SocketConnectionStatus.reconnecting);
      _scheduleReconnect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      try {
        if (_socket != null && _socket!.connected) {
          _socket!.emit('heartbeat', {'ts': DateTime.now().toIso8601String()});
        }
      } catch (_) {}
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectAttempts++;
    final delay = Duration(milliseconds: 500 * _reconnectAttempts);
    Future.delayed(delay, () {
      if (_socket != null && !_socket!.connected) {
        _statusController.add(SocketConnectionStatus.reconnecting);
        _socket!.connect();
      }
    });
  }

  void emit(String event, dynamic data) {
    if (_socket == null) return;
    try {
      _socket!.emit(event, data);
    } catch (_) {}
  }

  Stream<dynamic> on(String event) {
    if (!_eventControllers.containsKey(event)) {
      final controller = StreamController<dynamic>.broadcast();
      _eventControllers[event] = controller;
      _socket?.on(event, (data) => controller.add(data));
    }
    return _eventControllers[event]!.stream;
  }

  void off(String event) {
    if (_eventControllers.containsKey(event)) {
      _eventControllers[event]!.close();
      _eventControllers.remove(event);
      _socket?.off(event);
    }
  }

  Future<void> disconnect({bool force = false}) async {
    _stopHeartbeat();
    try {
      _socket?.disconnect();
    } catch (_) {}
    _socket?.dispose();
    _socket = null;
    _statusController.add(SocketConnectionStatus.disconnected);
  }

  void dispose() {
    _stopHeartbeat();
    for (final c in _eventControllers.values) {
      c.close();
    }
    _eventControllers.clear();
    _statusController.close();
    _socket?.dispose();
  }
}
