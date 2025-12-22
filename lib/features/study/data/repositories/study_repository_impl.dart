import 'package:dartz/dartz.dart';
import '../../domain/entities/study_entity.dart';
import '../../domain/repositories/study_repository.dart';
import '../datasources/study_remote_datasource.dart';

class StudyRepositoryImpl implements StudyRepository {
  final StudyRemoteDataSource remoteDataSource;

  StudyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<StudyEntity>>> getDueCards() async {
    try {
      final studies = await remoteDataSource.getDueCards();
      return Right(studies.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left('Study error: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ReviewResultEntity>> reviewCard(
      String cardId, int quality) async {
    try {
      final result = await remoteDataSource.reviewCard(cardId, quality);
      return Right(result.toEntity());
    } catch (e) {
      return Left('Study error: ${e.toString()}');
    }
  }
}
