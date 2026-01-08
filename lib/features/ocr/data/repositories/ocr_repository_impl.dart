import 'package:dartz/dartz.dart';
import '../../../../core/utils/universal_file.dart';
import '../../domain/entities/ocr_entity.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../datasources/ocr_remote_datasource.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource remoteDataSource;

  OcrRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, OcrResponseEntity>> processImage({
    required File imageFile,
    required String deckId,
  }) async {
    try {
      final result = await remoteDataSource.processImage(
        imageFile: imageFile,
        deckId: deckId,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left('OCR error: ${e.toString()}');
    }
  }
}
