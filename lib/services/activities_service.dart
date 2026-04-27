import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';

class Activity {
  final String id;
  final String type;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final String userFirstName;
  final String userLastName;

  Activity({
    required this.id,
    required this.type,
    this.metadata,
    required this.createdAt,
    required this.userFirstName,
    required this.userLastName,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      userFirstName: json['user']['firstName'],
      userLastName: json['user']['lastName'],
    );
  }
}

class ActivitiesService {
  final ApiClient _apiClient;

  ActivitiesService(this._apiClient);

  Future<List<Activity>> fetchLeadActivities(String leadId) async {
    try {
      final response = await _apiClient.get('/activities/lead/$leadId');
      final List data = response.data['data'];
      return data.map((json) => Activity.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final activitiesServiceProvider = Provider<ActivitiesService>((ref) {
  return ActivitiesService(ref.watch(apiClientProvider));
});
