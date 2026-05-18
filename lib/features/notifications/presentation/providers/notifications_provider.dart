import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification_model.dart';
import '../../../../services/notifications_service.dart';

final notificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final service = ref.watch(notificationsServiceProvider);
  return service.fetchNotifications();
});