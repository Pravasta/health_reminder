import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService with WidgetsBindingObserver {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  WebSocketChannel? _channel;

  bool _isConnected = false;
  int _retryCount = 0;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  void connect(String url) {
    if (_isConnected) return;

    WidgetsBinding.instance.addObserver(this);

    _openConnection(url);
  }

  void _openConnection(String url) {
    try {
      print('Attempting to connect to WebSocket: $url');

      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      _retryCount = 0;

      _startHeartbeat();

      _channel!.stream.listen(
        _handleMessage,
        onDone: () => _handleDisconnect(url),
        onError: (error) => _handleDisconnect(url),
      );
    } catch (e) {
      _scheduleReconnect(url);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);

      print('Received WebSocket message: $data');

      _messageController.add(data);
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void _handleDisconnect(String url) {
    print('WebSocket disconnected. Scheduling reconnect...');
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _scheduleReconnect(url);
  }

  void _scheduleReconnect(String url) {
    _channel = null;

    final delay = Duration(seconds: 2 << _retryCount);

    _retryCount = (_retryCount + 1).clamp(0, 5);
    print('Reconnecting in ${delay.inSeconds} seconds...');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () => _openConnection(url));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (e) {
        print('Error sending ping: $e');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isConnected) {
      print('App resumed. Attempting to reconnect WebSocket...');
      _reconnectTimer?.cancel();
      _openConnection(_channel?.sink.toString() ?? '');
    }
  }

  void _disconnect() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    _disconnect();
    _messageController.close();
  }
}
