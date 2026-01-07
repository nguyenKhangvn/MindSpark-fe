import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../network/dio_api_client.dart';
import '../../utils/universal_file.dart';
import '../models/ocr_models.dart';

class OcrService {
  final DioApiClient _apiClient;

  OcrService(this._apiClient);

  /// Process image using OCR API - Client-Side Upload Flow
  /// Step 1: Get Cloudinary signature
  /// Step 2: Upload to Cloudinary directly
  /// Step 3: Send imageUrl to API Gateway
  Future<Either<String, OcrResponse>> processImage({
    required File imageFile,
    required String deckId,
  }) async {
    try {
      print(' Starting client-side upload flow...');

      // Step 1: Get Cloudinary upload signature
      print('1️⃣ Getting Cloudinary signature...');
      final signatureResponse = await _apiClient.get('/upload/signature');

      if (signatureResponse.statusCode != 200) {
        return const Left('Failed to get upload signature');
      }

      final signatureData = signatureResponse.data['data'];
      print(' Signature received: ${signatureData['uploadUrl']}');

      // Step 2: Upload image directly to Cloudinary
      print('2️⃣ Uploading to Cloudinary...');
      final imageUrl = await _uploadToCloudinary(imageFile, signatureData);

      if (imageUrl == null) {
        return const Left('Failed to upload image to Cloudinary');
      }

      print(' Image uploaded: $imageUrl');

      // Step 3: Send OCR request to API Gateway with imageUrl
      print('3️⃣ Sending OCR request to API Gateway...');
      final response = await _apiClient.post(
        '/ai/ocr',
        data: {
          'imageUrl': imageUrl,
          'deckId': deckId,
        },
      );

      // Parse response (202 Accepted)
      if (response.statusCode == 202 || response.statusCode == 200) {
        print(' OCR request accepted: ${response.data}');

        // Return empty response since OCR is processing async
        return Right(OcrResponse(
          fullText: 'Processing...',
          cards: [],
          rawOcrDetails: [],
        ));
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

/// Upload image to Cloudinary directly
Future<String?> _uploadToCloudinary(
  File imageFile,
  Map<String, dynamic> signatureData,
) async {
  try {
    final dio = Dio(); // Use separate Dio instance for Cloudinary

    // Prepare multipart file
    MultipartFile multipartFile;
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;
      multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
    } else {
      multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      );
    }

    // Prepare form data for Cloudinary
    final formData = FormData.fromMap({
      'file': multipartFile,
      'api_key': signatureData['apiKey'],
      'timestamp': signatureData['timestamp'],
      'signature': signatureData['signature'],
      'folder': signatureData['folder'],
    });

    // Upload to Cloudinary
    final response = await dio.post(
      signatureData['uploadUrl'],
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      return response.data['secure_url'];
    } else {
      print(' Cloudinary upload failed: ${response.data}');
      return null;
    }
  } catch (e) {
    print(' Cloudinary upload error: $e');
    return null;
  }
}
