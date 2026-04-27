import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Today
          _buildDateHeader('Today'),
          _buildNotificationItem(
            context,
            title: 'New Lead Assigned',
            time: '2m ago',
            desc: 'Sarah Jenkins assigned to you. Review her profile and contact information.',
            icon: Icons.person_add,
            iconBgColor: AppColors.secondaryContainer,
            iconColor: AppColors.onSecondaryContainer,
            status: 'SUCCESS',
            statusColor: AppColors.secondaryFixed,
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            context,
            title: 'Task Due',
            time: '45m ago',
            desc: 'Property tour scheduled for 2:00 PM at 452 Oak Avenue.',
            icon: Icons.calendar_today,
            iconBgColor: AppColors.errorContainer,
            iconColor: AppColors.error,
            status: 'URGENT',
            statusColor: AppColors.errorContainer,
            isUrgent: true,
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            context,
            title: 'Price Drop Alert',
            time: '3h ago',
            desc: '3BR Condo in Downtown price reduced by \$15,000.',
            icon: Icons.trending_down,
            iconBgColor: AppColors.primaryContainer,
            iconColor: AppColors.onPrimaryContainer,
          ),

          const SizedBox(height: 32),

          // Yesterday
          _buildDateHeader('Yesterday'),
          _buildNotificationItem(
            context,
            title: 'Follow-up Reminder',
            time: 'Yesterday, 10:15 AM',
            desc: 'Call Robert King about Downtown Condo interest.',
            icon: Icons.call,
            iconBgColor: AppColors.tertiaryFixed,
            iconColor: AppColors.onTertiaryFixedVariant,
            status: 'FOLLOW-UP',
            statusColor: AppColors.tertiaryFixedDim,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDPr_9kr6YRE6z6QEyZkByzY2FYGGgNMfnl1ZC8okVSTbcUrIPYCsCUL7sc8YltaBqSakJa6IbR1hJ2NXRZB3xmlf6_kEqi-VXXh1oRlvgp1cNKFON8TDuySDxfwO4y-zyEy_kmbXa8b_K6ksfV2KD7Yj59cPF8yYNABrURz6OnsodZ3w4a4aagMVsDbEZODc8RZQmwurgx6p6NXxG1mmvwyPFG1khJE1A9qgkzwjFsfrCZsjTQakWpbjxIB4crw0ihqmdMi_P3Jqo2'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Update Complete', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Text('The MLS sync for the Downtown area is now finalized.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.2))),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String time,
    required String desc,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    String? status,
    Color? statusColor,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: isUrgent ? const BorderSide(color: AppColors.error, width: 4) : BorderSide.none),
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
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.5)),
                if (status != null && statusColor != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isUrgent ? AppColors.onErrorContainer : AppColors.onSecondaryFixed,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
