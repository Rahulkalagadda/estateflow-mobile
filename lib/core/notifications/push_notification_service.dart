import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.read(apiClientProvider));
});

class PushNotificationService {
  static const String _channelId = 'urgent_notifications';
  static const String _channelName = 'Urgent notifications';
  static const String _channelDescription = 'High priority CRM alerts';

  final ApiClient _apiClient;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  PushNotificationService(this._apiClient);

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);
      await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Tapping a notification opens the app; the list will refresh on resume.
        },
      );

      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.instance.onTokenRefresh.listen((_) async {
        await syncTokenWithBackend();
      });

      _initialized = true;
    } catch (_) {
      // Firebase may not be configured yet in local environments.
    }
  }

  Future<String?> currentToken() async {
    try {
      return FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> syncTokenWithBackend() async {
    final token = await currentToken();
    if (token == null || token.isEmpty) return;

    try {
      await _apiClient.dio.post('/auth/push-token', data: {'token': token});
    } catch (_) {
      // Ignore token sync failures; the app will retry on next login/token refresh.
    }
  }

  Future<void> clearTokenOnBackend() async {
    try {
      await _apiClient.dio.post('/auth/push-token', data: {'token': null});
    } catch (_) {
      // Ignore token cleanup failures.
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString() ?? 'Notification';
    final body = notification?.body ?? message.data['message']?.toString() ?? '';

    if (title.isEmpty && body.isEmpty) return;

    await _localNotifications.show(
      id: notification?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}