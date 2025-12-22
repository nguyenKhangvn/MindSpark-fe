import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/services/ocr_service.dart';
import '../../../../core/utils/universal_file.dart';
import 'ocr_state.dart';

class OcrCubit extends Cubit<OcrState> {
  final OcrService _ocrService;

  OcrCubit(this._ocrService) : super(OcrInitial());

  /// Process image using OCR API
  Future<void> processImage({
    required File imageFile,
  }) async {
    emit(OcrProcessing());

    final result = await _ocrService.processImage(
      imageFile: imageFile,
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
