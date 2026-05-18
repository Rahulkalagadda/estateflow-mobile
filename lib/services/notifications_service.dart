import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/notification_model.dart';
import '../core/network/api_client.dart';

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(ref.read(apiClientProvider));
});

class NotificationsService {
  final ApiClient _apiClient;

  NotificationsService(this._apiClient);

  Future<List<NotificationModel>> fetchNotifications({int page = 1, int limit = 25}) async {
    final response = await _apiClient.dio.get(
      '/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );

    final List data = (response.data['data'] as List?) ?? const [];
    return data.map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.dio.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.dio.patch('/notifications/read-all');
  }
}