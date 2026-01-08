import 'package:dartz/dartz.dart';
import '../../../../core/utils/universal_file.dart';
import '../entities/ocr_entity.dart';
import '../repositories/ocr_repository.dart';

class ProcessImageUseCase {
  final OcrRepository repository;

  ProcessImageUseCase(this.repository);

  Future<Either<String, OcrResponseEntity>> call({
    required File imageFile,
    required String deckId,
  }) {
    return repository.processImage(
      imageFile: imageFile,
      deckId: deckId,
    );
  }
}
