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

  String? _lastEventId; 

  Stream<Map<String, dynamic>> get ocrFinishedStream =>
      _ocrFinishedController.stream;

  void connect(String baseUrl, String userId, String accessToken) {
    // 1. Kiểm tra nếu socket đã tồn tại và đang kết nối
    if (_socket != null && _socket!.connected) {
      print('Socket already connected. Skipping.');
      return;
    }

    // Nếu socket tồn tại nhưng bị ngắt, dispose để tạo mới
    if (_socket != null) {
      _socket!.dispose();
    }

    print(' Connecting to WebSocket: $baseUrl');

    // 2. Cấu hình Socket với Token Authentication
    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Bắt buộc dùng websocket
          .disableAutoConnect() // Tắt auto connect để tự control
          .setAuth({'token': accessToken}) // Gửi token cho Server AuthGuard
          .setExtraHeaders({
            'Authorization': 'Bearer $accessToken'
          }) // Dự phòng nếu server check header
          .build(),
    );

    // 3. Bắt đầu kết nối
    _socket!.connect();

    // --- LẮNG NGHE SỰ KIỆN ---

    _socket!.onConnect((_) {
      print(' Socket connected successfully!');
      // Join room theo userId để nhận notification
      _socket!.emit('join_user_room', {'userId': userId});
    });

    _socket!.on('joined_room', (data) {
      print('Joined room: ${data['userId']}');
    });

    _socket!.on('ocr_finished', (data) {
      // Prevent duplicate events
      final eventId = '${data['deckId']}_${data['cardsCount']}';
      if (_lastEventId == eventId) {
        return; // Silently skip duplicate
      }
      _lastEventId = eventId;

      print(' Received OCR event: ${data['cardsCount']} cards');
      _ocrFinishedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.onDisconnect((data) {
      print(' Socket disconnected. Reason: $data');
      // Có thể xử lý logout nếu disconnect do lỗi token (401)
    });

    _socket!.onConnectError((error) {
      print(' Socket connection error: $error');
      // Thường lỗi này do server từ chối connection (sai token, sai url)
    });

    _socket!.onError((error) {
      print(' Socket error: $error');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose(); // Dọn dẹp bộ nhớ
      _socket = null;
      print(' Socket disconnected manually');
    }
  }

  void dispose() {
    disconnect();
    _ocrFinishedController.close();
  }
}
