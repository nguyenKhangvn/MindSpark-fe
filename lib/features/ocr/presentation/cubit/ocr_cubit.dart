import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/universal_file.dart';
import '../../domain/usecases/process_image_usecase.dart';
import 'ocr_state.dart';

class OcrCubit extends Cubit<OcrState> {
  final ProcessImageUseCase processImageUseCase;

  OcrCubit({required this.processImageUseCase}) : super(OcrInitial());

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
}
