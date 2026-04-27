import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/activities_service.dart';

class ActivitiesState {
  final List<Activity> activities;
  final bool isLoading;
  final String? error;

  ActivitiesState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
  });

  ActivitiesState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? error,
  }) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  final ActivitiesService _service;

  ActivitiesNotifier(this._service) : super(ActivitiesState());

  Future<void> fetchActivities(String leadId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final activities = await _service.fetchLeadActivities(leadId);
      state = state.copyWith(activities: activities, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final activitiesProvider = StateNotifierProvider.family<ActivitiesNotifier, ActivitiesState, String>((ref, leadId) {
  final notifier = ActivitiesNotifier(ref.watch(activitiesServiceProvider));
  notifier.fetchActivities(leadId);
  return notifier;
});
