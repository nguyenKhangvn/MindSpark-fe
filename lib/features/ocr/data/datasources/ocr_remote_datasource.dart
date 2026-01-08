import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/network/dio_api_client.dart';
import '../../../../core/utils/universal_file.dart';
import '../models/ocr_model.dart';

abstract class OcrRemoteDataSource {
  Future<OcrResponseModel> processImage({
    required File imageFile,
    required String deckId,
  });
}

class OcrRemoteDataSourceImpl implements OcrRemoteDataSource {
  final DioApiClient _apiClient;

  OcrRemoteDataSourceImpl(this._apiClient);

  @override
  Future<OcrResponseModel> processImage({
    required File imageFile,
    required String deckId,
  }) async {
    // Step 1: Get Cloudinary upload signature
    final signatureResponse = await _apiClient.get('/upload/signature');

    if (signatureResponse.statusCode != 200) {
      throw Exception('Failed to get upload signature');
    }

    final signatureData = signatureResponse.data['data'];

    // Step 2: Upload image directly to Cloudinary
    final imageUrl = await _uploadToCloudinary(imageFile, signatureData);

    if (imageUrl == null) {
      throw Exception('Failed to upload image to Cloudinary');
    }

    // Step 3: Send OCR request to API Gateway with imageUrl
    final response = await _apiClient.post(
      '/ai/ocr',
      data: {
        'imageUrl': imageUrl,
        'deckId': deckId,
      },
    );

    // Parse response (202 Accepted)
    if (response.statusCode == 202 || response.statusCode == 200) {
      // Return empty response since OCR is processing async
      return const OcrResponseModel(
        fullText: 'Processing...',
        cards: [],
        rawOcrDetails: [],
      );
    } else {
      throw Exception(response.data['message'] ?? 'OCR processing failed');
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
      return null;
    }
  } catch (e) {
    return null;
  }
}
