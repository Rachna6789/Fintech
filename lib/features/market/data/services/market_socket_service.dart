import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/config/env_config.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/market_connection_status.dart';
import '../../domain/entities/market_quote.dart';
import '../models/market_quote_model.dart';

class MarketSocketService {
  MarketSocketService({
    required EnvConfig config,
    required SecureStorageService secureStorageService,
  })  : _config = config,
        _secureStorageService = secureStorageService;

  static const _quoteEvent = 'market:quote';
  static const _subscribeEvent = 'market:subscribe';
  static const _unsubscribeEvent = 'market:unsubscribe';

  final EnvConfig _config;
  final SecureStorageService _secureStorageService;
  final _statusController =
      StreamController<MarketConnectionStatus>.broadcast();
  final _quoteController = StreamController<MarketQuote>.broadcast();

  io.Socket? _socket;
  List<String> _symbols = const [];

  Stream<MarketConnectionStatus> get statusStream => _statusController.stream;
  Stream<MarketQuote> get quoteStream => _quoteController.stream;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    _statusController.add(MarketConnectionStatus.connecting);
    final token = await _secureStorageService.readAuthToken();

    _socket = io.io(
      _config.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(1000)
          .setExtraHeaders({
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          })
          .build(),
    );

    _registerListeners(_socket!);
    _socket!.connect();
  }

  Future<void> reconnect() async {
    _statusController.add(MarketConnectionStatus.reconnecting);
    _socket?.disconnect();
    _socket?.connect();
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _statusController.add(MarketConnectionStatus.disconnected);
  }

  Future<void> subscribe(List<String> symbols) async {
    _symbols = symbols.map((symbol) => symbol.trim().toUpperCase()).toList();
    await connect();
    _socket?.emit(_subscribeEvent, {'symbols': _symbols});
  }

  Future<void> unsubscribe(List<String> symbols) async {
    final normalized =
        symbols.map((symbol) => symbol.trim().toUpperCase()).toList();
    _socket?.emit(_unsubscribeEvent, {'symbols': normalized});
    _symbols =
        _symbols.where((symbol) => !normalized.contains(symbol)).toList();
  }

  Future<void> dispose() async {
    await disconnect();
    await _statusController.close();
    await _quoteController.close();
  }

  void _registerListeners(io.Socket socket) {
    socket.onConnect((_) {
      _statusController.add(MarketConnectionStatus.connected);
      if (_symbols.isNotEmpty) {
        socket.emit(_subscribeEvent, {'symbols': _symbols});
      }
    });

    socket.onDisconnect((_) {
      _statusController.add(MarketConnectionStatus.disconnected);
    });

    socket.onReconnect((_) {
      _statusController.add(MarketConnectionStatus.connected);
    });

    socket.onReconnectAttempt((_) {
      _statusController.add(MarketConnectionStatus.reconnecting);
    });

    socket.onConnectError((_) {
      _statusController.add(MarketConnectionStatus.error);
    });

    socket.onError((_) {
      _statusController.add(MarketConnectionStatus.error);
    });

    socket.on(_quoteEvent, (payload) {
      if (payload is Map) {
        _quoteController.add(
          MarketQuoteModel.fromJson(Map<String, dynamic>.from(payload)),
        );
      }
    });
  }
}
