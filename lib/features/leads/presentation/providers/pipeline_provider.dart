import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pipeline_service.dart';
import '../core/models/pipeline_stage_model.dart';

class PipelineState {
  final bool isLoading;
  final List<PipelineStageModel> stages;
  final String? error;

  PipelineState({
    this.isLoading = false,
    this.stages = const [],
    this.error,
  });

  PipelineState copyWith({
    bool? isLoading,
    List<PipelineStageModel>? stages,
    String? error,
  }) {
    return PipelineState(
      isLoading: isLoading ?? this.isLoading,
      stages: stages ?? this.stages,
      error: error,
    );
  }
}

final pipelineProvider = StateNotifierProvider<PipelineNotifier, PipelineState>((ref) {
  final service = ref.watch(pipelineServiceProvider);
  return PipelineNotifier(service);
});

class PipelineNotifier extends StateNotifier<PipelineState> {
  final PipelineService _service;

  PipelineNotifier(this._service) : super(PipelineState()) {
    fetchStages();
  }

  Future<void> fetchStages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stages = await _service.fetchStages();
      state = state.copyWith(isLoading: false, stages: stages);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
