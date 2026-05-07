import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/models/activity_model.dart';

import 'providers/activity_provider.dart';
import '../../leads/presentation/providers/leads_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.firstName ?? 'User';
    final activityState = ref.watch(activityProvider);
    final leadState = ref.watch(leadsProvider);
    final leads = leadState.leads;

    // Calculate dynamic stats
    final totalLeads = leads.length.toString();
    final todayLeads = leads.where((l) => 
      l.createdAt.day == DateTime.now().day && 
      l.createdAt.month == DateTime.now().month && 
      l.createdAt.year == DateTime.now().year
    ).length.toString();
    final interestedLeads = leads.where((l) => l.stageId.toUpperCase().contains('INTERESTED')).length.toString();
    final closedLeads = leads.where((l) => l.stageId.toUpperCase().contains('CLOSED')).length.toString();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Estate Logic', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting
            Text('Good morning, $userName', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Text('Your pipeline is looking strong.', style: TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 32),

            // Bento Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  context,
                  title: 'Total',
                  value: totalLeads,
                  subtitle: 'Active Leads',
                  icon: Icons.group,
                  backgroundColor: AppColors.primaryContainer,
                  textColor: Colors.white,
                  iconColor: Colors.white70,
                ),
                _buildStatCard(
                  context,
                  title: 'Today',
                  value: todayLeads,
                  subtitle: 'New Today',
                  icon: Icons.event_repeat,
                  backgroundColor: AppColors.tertiaryFixedDim,
                  textColor: AppColors.onTertiaryFixed,
                  iconColor: AppColors.onTertiaryFixed,
                ),
                _buildStatCard(
                  context,
                  title: 'Interested',
                  value: interestedLeads,
                  subtitle: 'Interested',
                  icon: Icons.star,
                  backgroundColor: AppColors.secondaryContainer,
                  textColor: AppColors.onSecondaryFixed,
                  iconColor: AppColors.onSecondaryFixed,
                  hideTitle: true,
                ),
                _buildStatCard(
                  context,
                  title: 'Closed Deals',
                  value: closedLeads,
                  subtitle: 'Closed Deals',
                  icon: Icons.handshake,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  textColor: AppColors.primary,
                  iconColor: AppColors.primary,
                  hideTitle: true,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'QUICK ACTIONS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/leads/create'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Lead'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/leads'),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Leads'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.onSurface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT ACTIVITY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/notifications'),
                  child: const Text('See All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (activityState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (activityState.activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No recent activity.', style: TextStyle(color: Colors.grey)),
              )
            else
              ...activityState.activities.map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildActivityItem(context, activity),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    bool hideTitle = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor),
              if (!hideTitle)
                Text(
                  title.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconColor, letterSpacing: 1),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityModel activity) {
    IconData icon = Icons.notifications;
    Color iconBgColor = AppColors.surfaceContainerHigh;
    Color iconColor = AppColors.primary;

    switch (activity.type) {
      case 'LEAD_CREATED':
        icon = Icons.person_add;
        iconBgColor = const Color(0xFFEEF2FF);
        iconColor = const Color(0xFF4F46E5);
        break;
      case 'STAGE_CHANGED':
        icon = Icons.sync;
        iconBgColor = const Color(0xFFFFF7ED);
        iconColor = const Color(0xFFF97316);
        break;
      case 'TASK_COMPLETED':
        icon = Icons.task_alt;
        iconBgColor = const Color(0xFFF0FDF4);
        iconColor = const Color(0xFF22C55E);
        break;
      case 'NOTE_ADDED':
        icon = Icons.description;
        iconBgColor = const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF3B82F6);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  activity.displayDescription,
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            _getTimeAgo(activity.createdAt),
            style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
