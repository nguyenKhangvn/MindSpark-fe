import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Text-to-Speech Service
/// Hỗ trợ đọc tiếng Nhật và tiếng Việt
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    if (_isInitialized) return;

    try {
      // Cấu hình chung
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5); // Tốc độ đọc (0.0 - 1.0)
      await _flutterTts.setPitch(1.0); // Cao độ giọng nói

      // Platform specific settings
      if (!kIsWeb) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.awaitSpeakCompletion(true);
      }

      _isInitialized = true;
      print(' TTS Service initialized');
    } catch (e) {
      print(' TTS init error: $e');
    }
  }

  /// Đọc text tiếng Nhật
  Future<void> speakJapanese(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await _flutterTts.setLanguage('ja-JP');
      await _flutterTts.speak(text);
      print('🔊 Speaking Japanese: $text');
    } catch (e) {
      print(' TTS Japanese error: $e');
    }
  }

  /// Đọc text tiếng Việt
  Future<void> speakVietnamese(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await _flutterTts.setLanguage('vi-VN');
      await _flutterTts.speak(text);
      print('🔊 Speaking Vietnamese: $text');
    } catch (e) {
      print(' TTS Vietnamese error: $e');
    }
  }

  /// Dừng đọc
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Tạm dừng
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Set tốc độ đọc (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  /// Set âm lượng (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  /// Kiểm tra ngôn ngữ có hỗ trợ không
  Future<List<dynamic>> getAvailableLanguages() async {
    return await _flutterTts.getLanguages;
  }

  /// Dispose
  void dispose() {
    _flutterTts.stop();
  }
}
