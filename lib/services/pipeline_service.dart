import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/models/pipeline_stage_model.dart';

final pipelineServiceProvider = Provider<PipelineService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PipelineService(apiClient);
});

class PipelineService {
  final ApiClient _apiClient;

  PipelineService(this._apiClient);

  Future<List<PipelineStageModel>> fetchStages() async {
    try {
      final response = await _apiClient.dio.get('/pipeline-stages');
      final List data = response.data['data'] ?? [];
      return data.map((json) => PipelineStageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pipeline stages: $e');
    }
  }
}
