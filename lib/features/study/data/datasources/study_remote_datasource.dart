import '../../../../core/network/dio_api_client.dart';
import '../models/study_model.dart';

abstract class StudyRemoteDataSource {
  Future<List<StudyModel>> getDueCards();
  Future<ReviewResultModel> reviewCard(String cardId, int quality);
}

class StudyRemoteDataSourceImpl implements StudyRemoteDataSource {
  final DioApiClient apiClient;

  StudyRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<StudyModel>> getDueCards() async {
    final response = await apiClient.get('/study/due');

    // Backend trả về một Map { "cards": [...], "total": 4 }
    // Bạn phải lấy giá trị của key 'cards'
    final List<dynamic> data = response.data['cards'] as List<dynamic>;

    return data
        .map((json) => StudyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReviewResultModel> reviewCard(String cardId, int rating) async {
    final response = await apiClient.post(
      '/study/review/$cardId',
      data: {'rating': rating},
    );
    return ReviewResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}
