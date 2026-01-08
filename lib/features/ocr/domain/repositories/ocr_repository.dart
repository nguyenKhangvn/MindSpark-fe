import 'package:dartz/dartz.dart';
import '../../../../core/utils/universal_file.dart';
import '../entities/ocr_entity.dart';

abstract class OcrRepository {
  Future<Either<String, OcrResponseEntity>> processImage({
    required File imageFile,
    required String deckId,
  });
}
