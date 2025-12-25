import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import Universal File của bạn
import '../../../../core/utils/universal_file.dart' as universal;
import '../../../../core/services/socket_service.dart';
import '../../../../core/storage/token_storage.dart';

import 'package:mindspark/features/card/presentation/cubit/card_cubit.dart';
import 'package:mindspark/features/card/presentation/cubit/card_state.dart';
import 'package:mindspark/features/deck/presentation/cubit/deck_cubit.dart';
import 'package:mindspark/features/deck/presentation/cubit/deck_state.dart';
import 'package:mindspark/features/ocr/presentation/cubit/ocr_cubit.dart';
import 'package:mindspark/features/ocr/presentation/cubit/ocr_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OcrResultScreen extends StatefulWidget {
  const OcrResultScreen({super.key});

  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  final List<Map<String, TextEditingController>> _cards = [];
  final ImagePicker _picker = ImagePicker();
  final SocketService _socketService = SocketService();
  StreamSubscription<Map<String, dynamic>>? _ocrSubscription;

  // CHỈNH SỬA: Dùng bytes để hiển thị ảnh trên mọi nền tảng (Web & Mobile đều hỗ trợ Image.memory)
  Uint8List? _imageBytes;

  // Trạng thái xử lý
  String? _selectedDeckId;
  bool _isProcessingOcrEvent = false;
  String? _lastProcessedEventId;

  bool _isWaitingForSocket = false;
  @override
  void initState() {
    super.initState();

    // ĐÚNG: Gọi API 1 lần duy nhất khi màn hình mở lên
    // Dùng addPostFrameCallback để đảm bảo context đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckCubit = context.read<DeckCubit>();
      // Chỉ gọi nếu chưa có dữ liệu (để tránh load lại nếu đã có)
      if (deckCubit.state is DeckInitial) {
        deckCubit.getDecks();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _selectedDeckId == null) {
      _selectedDeckId = args;
    }

    // Initialize WebSocket connection
    _initializeWebSocket();
  }

  void _initializeWebSocket() async {
    try {
      // Create TokenStorage instance
      final secureStorage = kIsWeb ? null : const FlutterSecureStorage();
      final tokenStorage = TokenStorage(secureStorage);
      await tokenStorage.init();

      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken != null) {
        // Parse userId from JWT token
        final userId = _parseUserIdFromToken(accessToken);

        if (userId != null) {
          // Connect to WebSocket
          _socketService.connect('http://localhost:3002', userId);

          // Listen to OCR finished events
          _ocrSubscription = _socketService.ocrFinishedStream.listen((data) {
            print('📬 OCR Finished event received: $data');

            // Prevent duplicate processing
            final eventId =
                '${data['deckId']}_${data['cardsCount']}_${data['message']}';
            if (_lastProcessedEventId == eventId || _isProcessingOcrEvent) {
              print('⏭️ Skipping duplicate OCR event');
              return;
            }

            if (data['deckId'] == _selectedDeckId && mounted) {
              _lastProcessedEventId = eventId;
              _handleOcrWebSocketEvent(data);
            }
          });
        }
      }
    } catch (e) {
      print(' Error initializing WebSocket: $e');
    }
  }

  String? _parseUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (middle part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = json.decode(decoded);

      return data['userId'] ?? data['sub'];
    } catch (e) {
      print(' Error parsing JWT: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _clearCurrentCards();
    _ocrSubscription?.cancel();
    super.dispose();
  }

  void _handleOcrWebSocketEvent(Map<String, dynamic> data) {
    if (!mounted || _isProcessingOcrEvent) return;

    _isProcessingOcrEvent = true;
    setState(() {
      _isWaitingForSocket = false;
    });
    print('📬 Processing OCR WebSocket event: $data');

    _clearCurrentCards();

    if (!mounted) {
      _isProcessingOcrEvent = false;
      return;
    }

    setState(() {
      final cards = data['cards'] as List<dynamic>? ?? [];
      final fullText = data['fullText'] as String? ?? '';

      if (cards.isNotEmpty) {
        // Populate cards from WebSocket event
        print('✅ Populating ${cards.length} cards from WebSocket');
        for (final card in cards) {
          final front = card['front'] ?? '';
          final back = card['back'] ?? '';
          final kanji = card['kanji'] ?? card['front'] ?? '';

          _cards.add(_createNewCard(front, kanji, back));
        }
      } else if (fullText.isNotEmpty) {
        // Fallback: Parse fullText if no cards provided
        print('⚠️ No cards in WebSocket event, parsing fullText');
        final lines =
            fullText.split('\n').where((l) => l.trim().isNotEmpty).toList();

        for (final line in lines) {
          final parts = line.split('-').map((e) => e.trim()).toList();
          if (parts.length >= 2) {
            _cards.add(_createNewCard(parts[0], parts[0], parts[1]));
          }
        }
      }

      // Add empty card if no cards found
      if (_cards.isEmpty) {
        _cards.add(_createNewCard('', '', ''));
      }
    });

    // Show snackbar notification with mounted check
    if (mounted) {
      _showSuccessSnackBar(
          'OCR hoàn thành! Đã phân tích ${_cards.length} thẻ.');
      // Show dialog with mounted check
      _showOcrCompleteDialog(data);
    }

    _isProcessingOcrEvent = false;
  }

  void _showOcrCompleteDialog(Map<String, dynamic> data) {
    if (!mounted) return;

    final cardsCount = data['cards']?.length ?? _cards.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.rate_review_outlined,
                color: Colors.blue, size: 32), // ✅ Đổi icon Review
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Phân tích hoàn tất!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI đã tìm thấy $cardsCount thẻ từ vựng.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng kiểm tra lại nội dung bên dưới và bấm "LƯU" để thêm vào bộ thẻ.', // ✅ Hướng dẫn đúng
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
            child: const Text(
                'Kiểm tra ngay'), // ✅ Chỉ cho phép đóng dialog để review
          ),
        ],
      ),
    );
  } // --- LOGIC XỬ LÝ ẢNH & OCR ---

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (picked != null && _selectedDeckId != null) {
        // 1. Đọc bytes để hiển thị lên UI (Chạy được cả Mobile và Web)
        final bytes = await picked.readAsBytes();

        setState(() {
          _imageBytes = bytes;
        });

        // 2. Tạo universal File để gửi cho Cubit xử lý
        universal.File universalFile;

        if (kIsWeb) {
          // Web: Cần bytes và path ảo
          universalFile = universal.File.fromBytes(picked.path, bytes);
        } else {
          // Mobile: Chỉ cần path là đủ (Universal File của bạn sẽ tự xử lý IO bên trong nó)
          universalFile = universal.File(picked.path);
        }

        // 3. Gọi OCR Cubit với deckId
        if (!mounted) return;
        context.read<OcrCubit>().processImage(
              imageFile: universalFile,
              deckId: _selectedDeckId!,
            );
      } else if (_selectedDeckId == null) {
        _showErrorSnackBar('Vui lòng chọn bộ thẻ trước khi chọn ảnh!');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi chọn ảnh: $e');
    }
  }

  void _handleOcrSuccess(OcrSuccess state) {
    _clearCurrentCards();

    // Debug: Kiểm tra response (fix RangeError)
    final fullText = state.response.fullText;
    final previewText =
        fullText.length > 50 ? fullText.substring(0, 50) : fullText;
    print(' OCR Response - Full Text: $previewText...');
    print(' OCR Response - Cards count: ${state.response.cards.length}');
    if (state.response.cards.isNotEmpty) {
      print(
          ' First card: ${state.response.cards.first.term} | ${state.response.cards.first.kanji} | ${state.response.cards.first.meaning}');
    }

    // Sử dụng cards đã được LLM parse sẵn từ backend
    setState(() {
      if (state.response.cards.isNotEmpty) {
        // Có cards từ LLM
        print(' Using ${state.response.cards.length} cards from LLM');
        for (final card in state.response.cards) {
          _cards.add(_createNewCard(
            card.term,
            card.kanji,
            card.meaning,
          ));
        }
      } else {
        // Fallback: Parse fullText nếu không có cards
        print(' No cards from LLM, using fallback parsing');
        final lines = state.response.fullText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();

        for (final line in lines) {
          final parts = line.split(RegExp(r'[:\-–—]'));
          final term = parts[0].trim();
          final meaning =
              parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

          _cards.add(_createNewCard(term, term, meaning));
        }
      }

      // Nếu không có card nào, thêm 1 card rỗng
      if (_cards.isEmpty) {
        _cards.add(_createNewCard('', '', ''));
      }
    });
  }

  Map<String, TextEditingController> _createNewCard(
      String term, String kanji, String meaning) {
    return {
      'term': TextEditingController(text: term),
      'kanji': TextEditingController(text: kanji),
      'meaning': TextEditingController(text: meaning),
    };
  }

  // --- LOGIC QUẢN LÝ THẺ ---
  // (Giữ nguyên như cũ)
  void _addEmptyCard() {
    setState(() {
      _cards.add(_createNewCard('', '', ''));
    });
  }

  void _deleteCard(int index) {
    setState(() {
      _cards[index]['term']?.dispose();
      _cards[index]['kanji']?.dispose();
      _cards[index]['meaning']?.dispose();
      _cards.removeAt(index);
    });
  }

  void _clearCurrentCards() {
    for (var card in _cards) {
      card['term']?.dispose();
      card['kanji']?.dispose();
      card['meaning']?.dispose();
    }
    _cards.clear();
  }

  // --- LOGIC LƯU VÀO CORE SERVICE ---
  // (Giữ nguyên như cũ)
  void _saveToDeck() {
    if (_selectedDeckId == null) {
      _showErrorSnackBar('Vui lòng chọn bộ thẻ trước!');
      return;
    }

    final Map<String, dynamic> requestBody = {
      'deckId': _selectedDeckId,
      'cards': _cards.map((card) {
        final frontText = card['term']?.text.trim() ?? '';
        final kanjiText = card['kanji']?.text.trim() ?? '';
        final backText = card['meaning']?.text.trim() ?? '';

        return {
          'front': frontText,
          'kanji': kanjiText.isNotEmpty ? kanjiText : null, // Gửi kanji nếu có
          'back': backText,
        };
      }).toList(),
    };

    context.read<CardCubit>().createCards(requestBody);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- GIAO DIỆN (UI) ---

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CardCubit, CardState>(
          listener: (context, state) {
            if (state is OcrSuccess) {
              //  BỔ SUNG: Bật cờ chờ Socket để giữ Loading không bị tắt
              setState(() {
                _isWaitingForSocket = true;
              });
              print(" Upload ảnh thành công, đang chờ AI qua Socket...");
            }
            if (state is CardsCreated) {
              if (!mounted) return;

              // Show success dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Thành công!',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã lưu ${_cards.length} thẻ vào bộ học!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close dialog
                        if (mounted) {
                          Navigator.of(context).pop(); // Back to deck screen
                        }
                      },
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            }
            if (state is CardError) {
              if (mounted) {
                _showErrorSnackBar('Lỗi: ${state.message}');
              }
            }
          },
        ),
        BlocListener<OcrCubit, OcrState>(
          listener: (context, state) {
            if (state is OcrSuccess) {
              print(" Upload ảnh thành công, đang chờ AI qua Socket...");
            }
            if (state is OcrError) {
              _showErrorSnackBar('Lỗi OCR: ${state.message}');
            }
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Kết quả OCR'),
              actions: [
                IconButton(
                  onPressed: () => _showImageSourceActionSheet(context),
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
              ],
            ),
            body: Column(
              children: [
                _buildDeckSelector(),
                _buildImagePreview(), // Đã sửa logic hiển thị
                _buildListHeader(),
                Expanded(child: _buildMainContent()),
              ],
            ),
            bottomNavigationBar: _buildBottomAction(),
          ),

          // Loading Overlay Logic (Giữ nguyên)
          BlocBuilder<OcrCubit, OcrState>(
            builder: (context, ocrState) {
              return BlocBuilder<CardCubit, CardState>(
                builder: (context, cardState) {
                  // 1. Đang upload ảnh (HTTP Request)
                  if (ocrState is OcrProcessing) {
                    return _buildLoadingOverlay('Đang tải ảnh lên...');
                  }

                  // 2. ✅ Upload xong, đang chờ AI qua Socket (Cái bạn đang thiếu)
                  if (_isWaitingForSocket) {
                    return _buildLoadingOverlay('AI đang phân tích ảnh...');
                  }

                  // 3. User bấm Lưu, đang lưu vào DB
                  if (cardState is CardLoading) {
                    return _buildLoadingOverlay('Đang lưu vào dữ liệu...');
                  }

                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget helper cho Loading
  Widget _buildLoadingOverlay(String text) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    // CHỈNH SỬA: Chỉ cần kiểm tra _imageBytes có dữ liệu hay không
    final hasImage = _imageBytes != null;

    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(context),
      child: Container(
        width: double.infinity,
        height: 180,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                // Dùng Image.memory để hiển thị trên cả Web và Mobile mà không cần dart:io
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.contain,
                ),
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Bấm để chọn ảnh từ vựng',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
      ),
    );
  }

  // --- CÁC WIDGET CON KHÁC (Giữ nguyên) ---
  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Kết quả phân tích (${_cards.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextButton.icon(
            onPressed: _addEmptyCard,
            icon: const Icon(Icons.add),
            label: const Text('Thêm thẻ'),
          )
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<OcrCubit, OcrState>(
      builder: (context, state) {
        if (_cards.isEmpty && state is! OcrProcessing) {
          return const Center(
              child: Text('Chưa có dữ liệu. Hãy quét một tấm ảnh!'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _cards.length,
          itemBuilder: (context, index) => _buildEditableCard(index),
        );
      },
    );
  }

  Widget _buildEditableCard(int index) {
    final card = _cards[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text('${index + 1}',
                      style:
                          const TextStyle(fontSize: 10, color: Colors.white)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.red, size: 20),
                  onPressed: () => _deleteCard(index),
                )
              ],
            ),
            const SizedBox(height: 8),
            _buildSmallField(
                card['term']!, 'Từ vựng (Hiragana)', Icons.text_fields),
            const SizedBox(height: 12),
            _buildSmallField(card['kanji']!, 'Hán tự (Kanji)', Icons.translate),
            const SizedBox(height: 12),
            _buildSmallField(
                card['meaning']!, 'Nghĩa tiếng Việt', Icons.edit_note),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: BlocBuilder<CardCubit, CardState>(
          builder: (context, state) {
            final bool isSaving = state is CardLoading;
            return ElevatedButton(
              onPressed: (_cards.isEmpty || isSaving) ? null : _saveToDeck,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      'LƯU ${_cards.length} THẺ VÀO BỘ HỌC',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeckSelector() {
    return BlocBuilder<DeckCubit, DeckState>(
      builder: (context, state) {
        if (state is DecksLoaded) {
          if (_selectedDeckId == null && state.decks.isNotEmpty) {
            _selectedDeckId = state.decks.first.id;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedDeckId,
              decoration: InputDecoration(
                labelText: 'Lưu vào bộ thẻ',
                prefixIcon: const Icon(Icons.folder, color: Colors.orange),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: state.decks.map((deck) {
                return DropdownMenuItem(value: deck.id, child: Text(deck.name));
              }).toList(),
              onChanged: (val) => setState(() => _selectedDeckId = val),
            ),
          );
        }
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: LinearProgressIndicator(),
        );
      },
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
