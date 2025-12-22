import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/study_usecases.dart';
import 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  final GetDueCardsUseCase getDueCardsUseCase;
  final ReviewCardUseCase reviewCardUseCase;

  StudyCubit({
    required this.getDueCardsUseCase,
    required this.reviewCardUseCase,
  }) : super(StudyInitial());

  Future<void> getDueCards() async {
    emit(StudyLoading());
    final result = await getDueCardsUseCase();
    result.fold(
      (error) => emit(StudyError(error)),
      (dueCards) => emit(DueCardsLoaded(dueCards)),
    );
  }

  Future<void> reviewCard(String cardId, int quality) async {
    emit(StudyLoading());

    final result = await reviewCardUseCase(cardId, quality);

    result.fold(
      (failure) {
        // Đổi tên thành failure để tránh nhầm lẫn
        String errorMessage;

        // Ép kiểu sang dynamic để thực hiện kiểm tra
        final dynamic error = failure;

        if (error is List) {
          // Nếu lỗi là mảng
          errorMessage = error.join(', ');
        } else if (error is Map) {
          // Kiểm tra an toàn: chỉ gọi containsKey khi chắc chắn là Map
          final msg = error['message'];
          errorMessage = msg is List ? msg.join(', ') : msg.toString();
        } else {
          // Nếu đã là String hoặc kiểu khác
          errorMessage = error.toString();
        }

        emit(StudyError(errorMessage));
      },
      (result) => emit(CardReviewed(result)),
    );
  }
}
