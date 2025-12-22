import 'package:equatable/equatable.dart';
import '../../../../core/api/models/ocr_models.dart';

abstract class OcrState extends Equatable {
  const OcrState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no OCR processing yet
class OcrInitial extends OcrState {}

/// Processing OCR - showing loading indicator
class OcrProcessing extends OcrState {}

/// OCR completed successfully - cards extracted
class OcrSuccess extends OcrState {
  final OcrResponse response;

  const OcrSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

/// OCR failed with error message
class OcrError extends OcrState {
  final String message;

  const OcrError(this.message);

  @override
  List<Object?> get props => [message];
}
