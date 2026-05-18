import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/notifications_provider.dart';
import '../../../services/notifications_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await ref.read(notificationsServiceProvider).markAllAsRead();
              ref.invalidate(notificationsProvider);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _EmptyNotificationsState(
              onRefresh: () async {
                ref.invalidate(notificationsProvider);
                await Future<void>.delayed(Duration.zero);
              },
            );
          }

          final grouped = _groupByDay(notifications);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              await Future<void>.delayed(Duration.zero);
            },
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildSummary(context, notifications),
                const SizedBox(height: 24),
                for (final entry in grouped.entries) ...[
                  _buildDateHeader(context, entry.key),
                  const SizedBox(height: 16),
                  for (final item in entry.value) ...[
                    _buildNotificationItem(
                      context,
                      notification: item,
                      onTap: () async {
                        if (!item.isRead) {
                          await ref.read(notificationsServiceProvider).markAsRead(item.id);
                          ref.invalidate(notificationsProvider);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Failed to load notifications: $error'),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, List<NotificationModel> notifications) {
    final unreadCount = notifications.where((item) => !item.isRead).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primaryContainer, context.colors.surfaceHighlight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inbox', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$unreadCount unread alerts', style: TextStyle(color: context.colors.onSurfaceVariant)),
            ],
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: context.colors.primary,
            child: Text('$unreadCount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: context.colors.onSurfaceVariant)),
          SizedBox(width: 16),
          Expanded(child: Container(height: 1, color: context.colors.outlineVariant.withValues(alpha: 0.2))),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required NotificationModel notification,
    required VoidCallback onTap,
  }) {
    final isUrgent = notification.isUrgent || !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border(left: isUrgent ? BorderSide(color: context.colors.error, width: 4) : BorderSide.none),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUrgent ? context.colors.errorContainer : context.colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUrgent ? Icons.notifications_active : Icons.notifications,
                color: isUrgent ? context.colors.onErrorContainer : context.colors.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_formatTime(notification.createdAt), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(notification.message, style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant, height: 1.5)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUrgent ? context.colors.errorContainer : context.colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isUrgent ? 'URGENT' : (notification.isRead ? 'READ' : 'NEW'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isUrgent ? context.colors.onErrorContainer : context.colors.onSecondaryFixed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<NotificationModel>> _groupByDay(List<NotificationModel> notifications) {
    final grouped = <String, List<NotificationModel>>{};
    for (final notification in notifications) {
      final diff = DateTime.now().difference(notification.createdAt).inDays;
      final key = diff <= 0 ? 'Today' : diff == 1 ? 'Yesterday' : '${notification.createdAt.month}/${notification.createdAt.day}/${notification.createdAt.year}';
      grouped.putIfAbsent(key, () => []).add(notification);
    }
    return grouped;
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyNotificationsState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 72, color: context.colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No notifications yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Urgent alerts and activity updates will show up here.', textAlign: TextAlign.center, style: TextStyle(color: context.colors.onSurfaceVariant)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
