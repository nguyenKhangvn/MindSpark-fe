// lib/core/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final _ocrFinishedController =
      StreamController<Map<String, dynamic>>.broadcast();
  
  String? _lastEventId; // Track last processed event to prevent duplicates

  Stream<Map<String, dynamic>> get ocrFinishedStream =>
      _ocrFinishedController.stream;

  void connect(String baseUrl, String userId) {
    if (_socket != null && _socket!.connected) {
      print('✅ Socket already connected');
      return;
    }

    print('🔌 Connecting to WebSocket: $baseUrl');

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected');
      // Join room theo userId để nhận notification
      _socket!.emit('join_user_room', {'userId': userId});
    });

    _socket!.on('joined_room', (data) {
      print('✅ Joined room: ${data['userId']}');
    });

    _socket!.on('ocr_finished', (data) {
      // Prevent duplicate events at source
      final eventId = '${data['deckId']}_${data['cardsCount']}';
      if (_lastEventId == eventId) {
        return; // Silently skip duplicate
      }
      _lastEventId = eventId;
      
      print('📨 Received OCR event: ${data['cardsCount']} cards');
      _ocrFinishedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    print('🔌 Socket disconnected manually');
  }

  void dispose() {
    disconnect();
    _ocrFinishedController.close();
  }
}
