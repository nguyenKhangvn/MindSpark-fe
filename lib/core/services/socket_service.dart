// lib/core/services/socket_service.dart

import 'dart:async';
import 'package:flutter/material.dart'; // Cần import để dùng showDialog, AlertDialog
import 'package:mindspark/core/services/navigation_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

//  HÃY SỬA ĐƯỜNG DẪN IMPORT NÀY THEO DỰ ÁN CỦA BẠN
import '../di/injection_container.dart'; // Nơi khai báo biến 'sl' (Service Locator)
import '../navigation/navigation_service.dart'; // File chứa NavigationService
import '../../routes/app_router.dart'; // File chứa tên route (AppRouter.ocrResult)

class SocketService {
  // Singleton Pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final _ocrFinishedController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Biến để check duplicate event
  String? _lastEventId;
  DateTime? _lastEventTime;

  // Biến để lưu danh sách các ID mà Socket ĐÃ hiện Dialog rồi
  final Set<String> _processedHistoryIds = {};

  Stream<Map<String, dynamic>> get ocrFinishedStream =>
      _ocrFinishedController.stream;

  //  MỚI: Hàm hỗ trợ để check từ bên ngoài (dùng trong HomeScreen)
  bool isIdProcessed(String historyId) {
    return _processedHistoryIds.contains(historyId);
  }

  void connect(String baseUrl, String userId, String accessToken) {
    // 1. Kiểm tra nếu socket đã tồn tại và đang kết nối
    if (_socket != null && _socket!.connected) {
      print(' Socket already connected. Skipping.');
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
      // Join room theo userId để nhận notification riêng tư
      _socket!.emit('join_user_room', {'userId': userId});
    });

    _socket!.on('joined_room', (data) {
      print('👤 Joined room: ${data['userId']}');
    });

    // XÓA listener cũ để tránh đăng ký nhiều lần
    _socket!.off('ocr_finished');
    
    //  SỰ KIỆN QUAN TRỌNG NHẤT: NHẬN KẾT QUẢ OCR
    _socket!.on('ocr_finished', (data) {
      try {
        // Kiểm tra data hợp lệ
        if (data == null || data['deckId'] == null) {
          return;
        }

        final now = DateTime.now();
        final deckId = data['deckId'].toString();
        final cardsCount = data['cardsCount']?.toString() ?? '0';
        final eventId = '${deckId}_$cardsCount';
        
        // Chặn event trùng lặp: cùng ID và trong vòng 3 giây
        if (_lastEventId == eventId && 
            _lastEventTime != null && 
            now.difference(_lastEventTime!).inSeconds < 3) {
          return; // Bỏ qua event trùng
        }
        
        _lastEventId = eventId;
        _lastEventTime = now;

        print('  OCR completed: $cardsCount cards (deck: $deckId)');

        // Đẩy vào Stream
        _ocrFinishedController.add(Map<String, dynamic>.from(data));

        // Hiện dialog
        _showResultDialog(Map<String, dynamic>.from(data));
      } catch (e) {
        print('  Error handling OCR event: $e');
      }
    });

    _socket!.onDisconnect((data) {
      print(' Socket disconnected. Reason: $data');
    });

    _socket!.onConnectError((error) {
      print(' Socket connection error: $error');
    });

    _socket!.onError((error) {
      print(' Socket error: $error');
    });
  }

  /// Hàm xử lý logic hiện Dialog toàn cục
  void _showResultDialog(Map<String, dynamic> data) {
    try {
      //  Đánh dấu ID này là "Đã xử lý"
      final historyId = data['ocrHistoryId'] ?? data['id'];
      if (historyId != null) {
        _processedHistoryIds.add(historyId.toString());
      }

      // Kiểm tra và chuyển đổi cardsCount sang String an toàn
      final cardsCountRaw = data['cardsCount'];
      if (cardsCountRaw == null) {
        return;
      }
      final cardsCountStr = cardsCountRaw.toString();

      // Lấy context từ NavigationService
      final context = sl<NavigationService>().navigatorKey.currentContext;

      if (context != null) {
        // Dùng addPostFrameCallback để an toàn
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Quét ảnh thành công!',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Text(
                'AI đã xử lý xong và tìm thấy $cardsCountStr thẻ từ vựng.\nBạn có muốn xem và lưu lại không?',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('Để sau',
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    sl<NavigationService>()
                        .navigatorKey
                        .currentState
                        ?.pushNamed(
                          AppRouter.ocrResult,
                          arguments: data,
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xem ngay'),
                ),
              ],
            ),
          );
        });
      } else {
        print(
            " Không tìm thấy Context (App có thể đang ở background hoặc chưa init Navigator)");
      }
    } catch (e) {
      print(" Lỗi khi cố hiện Dialog từ Socket: $e");
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      print(' Socket disconnected manually');
    }
  }

  void dispose() {
    disconnect();
    _ocrFinishedController.close();
  }
}