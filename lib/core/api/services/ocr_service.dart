import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert' show jsonDecode;
import '../../network/dio_api_client.dart';
import '../../utils/universal_file.dart';
import '../models/ocr_models.dart';

class OcrService {
  final DioApiClient _apiClient;

  OcrService(this._apiClient);

  /// Process image using OCR API
  /// Returns Either<String, OcrResponse>
  /// Left(error) on failure, Right(response) on success
  Future<Either<String, OcrResponse>> processImage({
    required File imageFile,
  }) async {
    try {
      // Create multipart request
      MultipartFile multipartFile;

      if (kIsWeb) {
        // Web: Read bytes from file
        final bytes = await imageFile.readAsBytes();
        final fileName = imageFile.path.split('/').last;
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        );
      } else {
        // Mobile: Use file path
        multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      final formData = FormData.fromMap({
        'file': multipartFile, // Backend mong đợi field name là 'file'
      });

      // Send POST request to OCR endpoint
      // Quan trọng: Không set Content-Type, để Dio tự động set multipart/form-data
      final response = await _apiClient.post(
        '/ai/ocr',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data', // Đảm bảo đúng content type
        ),
      );

      // Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('🔍 Raw response data: ${response.data}');
        print('🔍 Response data type: ${response.data.runtimeType}');

        // Handle case where response.data might be String instead of Map
        Map<String, dynamic> jsonData;
        if (response.data is String) {
          print('⚠️ Response is String, parsing JSON...');
          jsonData = jsonDecode(response.data);
        } else {
          jsonData = response.data;
        }

        print('🔍 Cards in response: ${jsonData['cards']}');
        print('🔍 Cards count: ${(jsonData['cards'] as List?)?.length ?? 0}');

        final ocrResponse = OcrResponse.fromJson(jsonData);
        print(
            '✅ Parsed OcrResponse - Cards count: ${ocrResponse.cards.length}');
        if (ocrResponse.cards.isNotEmpty) {
          print(
              '✅ First card: ${ocrResponse.cards.first.term} | ${ocrResponse.cards.first.meaning}');
        }

        return Right(ocrResponse);
      } else {
        return Left(response.data['message'] ?? 'OCR processing failed');
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return e.response?.data['message'] ?? 'Server error occurred';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error: ${e.message}';
    }
  }
}
