import 'package:dartz/dartz.dart';
import '../entities/study_entity.dart';
import '../repositories/study_repository.dart';

class GetDueCardsUseCase {
  final StudyRepository repository;
  GetDueCardsUseCase(this.repository);

  Future<Either<String, List<StudyEntity>>> call() {
    return repository.getDueCards();
  }
}

class ReviewCardUseCase {
  final StudyRepository repository;
  ReviewCardUseCase(this.repository);

  Future<Either<String, ReviewResultEntity>> call(String cardId, int quality) {
    return repository.reviewCard(cardId, quality);
  }
}
