import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/universal_file.dart';
import '../../../../core/network/dio_api_client.dart';
import '../../domain/usecases/process_image_usecase.dart';
import '../../data/models/ocr_history_model.dart';
import 'ocr_state.dart';

class OcrCubit extends Cubit<OcrState> {
  final ProcessImageUseCase processImageUseCase;
  final DioApiClient apiClient;

  OcrCubit({
    required this.processImageUseCase,
    required this.apiClient,
  }) : super(OcrInitial());

  /// Process image using OCR API
  Future<void> processImage({
    required File imageFile,
    required String deckId,
  }) async {
    emit(OcrProcessing());

    final result = await processImageUseCase(
      imageFile: imageFile,
      deckId: deckId,
    );

    result.fold(
      (error) => emit(OcrError(error)),
      (response) => emit(OcrSuccess(response)),
    );
  }

  /// Reset to initial state
  void reset() {
    emit(OcrInitial());
  }

  /// Get pending OCR histories from backend
  Future<void> getPendingOcrHistories() async {
    emit(OcrPendingLoading());

    try {
      final response = await apiClient.get('/ocr-callback/pending');
      final data = response.data;

      final List<dynamic> results = data['results'] ?? [];
      final int count = data['count'] ?? 0;

      final histories = results
          .map((json) => OcrHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(OcrPendingLoaded(histories, count));
    } catch (e) {
      emit(OcrError('Failed to load pending OCR: $e'));
    }
  }

  /// Mark OCR history as completed
  Future<void> markOcrHistoryComplete(String historyId) async {
    try {
      await apiClient.patch('/ocr-callback/$historyId/complete');
      emit(OcrHistoryCompleted(historyId));
    } catch (e) {
      emit(OcrError('Failed to mark OCR complete: $e'));
    }
  }
}
