import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/activity_model.dart';
import '../../../../core/network/api_client.dart';

final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService(ref.watch(apiClientProvider));
});

class ActivityService {
  final ApiClient _apiClient;
  ActivityService(this._apiClient);

  Future<List<ActivityModel>> fetchActivities() async {
    try {
      final response = await _apiClient.dio.get('/activities');
      final List data = response.data['data'] ?? [];
      return data.map((json) => ActivityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch activities: $e');
    }
  }
}

class ActivityState {
  final bool isLoading;
  final List<ActivityModel> activities;

  ActivityState({this.isLoading = false, this.activities = const []});
}

final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier(ref.watch(activityServiceProvider));
});

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ActivityService _service;

  ActivityNotifier(this._service) : super(ActivityState()) {
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    state = ActivityState(isLoading: true, activities: state.activities);
    try {
      final activities = await _service.fetchActivities();
      state = ActivityState(isLoading: false, activities: activities);
    } catch (e) {
      state = ActivityState(isLoading: false, activities: state.activities);
    }
  }
}
