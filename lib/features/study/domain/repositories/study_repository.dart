import 'package:dartz/dartz.dart';
import '../entities/study_entity.dart';

abstract class StudyRepository {
  Future<Either<String, List<StudyEntity>>> getDueCards();
  Future<Either<String, ReviewResultEntity>> reviewCard(
      String cardId, int quality);
}
