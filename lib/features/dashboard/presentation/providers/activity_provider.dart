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
    await Future.delayed(const Duration(seconds: 1));
    return [
      ActivityModel(
        id: '1',
        type: 'Call',
        title: 'Call with Sarah Jenkins',
        description: 'Discussed the property requirements.',
        leadId: '1',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        status: 'Completed',
      ),
      ActivityModel(
        id: '2',
        type: 'Note',
        title: 'New lead: James Wilson',
        description: 'Added to the system.',
        leadId: '2',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Pending',
      ),
    ];
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
