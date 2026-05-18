import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/models/activity_model.dart';

import 'providers/activity_provider.dart';
import '../../leads/presentation/providers/leads_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _onRefresh() async {
    // In a real app, you would refresh the providers
    ref.invalidate(leadsProvider);
    ref.invalidate(activityProvider);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.firstName ?? 'User';
    final activityState = ref.watch(activityProvider);
    final leadState = ref.watch(leadsProvider);
    final leads = leadState.leads;

    // Calculate dynamic stats
    final totalLeads = leads.length;
    final todayLeads = leads.where((l) => 
      l.createdAt.day == DateTime.now().day && 
      l.createdAt.month == DateTime.now().month && 
      l.createdAt.year == DateTime.now().year
    ).length;
    final interestedLeads = leads.where((l) => l.stageId.toUpperCase().contains('INTERESTED')).length;
    final closedLeads = leads.where((l) => l.stageId.toUpperCase().contains('CLOSED')).length;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: context.colors.primary,
        backgroundColor: context.colors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Sticky Header
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: context.colors.background.withValues(alpha: 0.9),
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: Text(
                  'Estate Logic',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20),
                ),
                background: Container(color: Colors.transparent),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceHighlight,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.outlineVariant),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.person_outline, color: context.colors.onBackground),
                    onPressed: () => context.push('/profile'),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting
                    Text('Good morning, $userName', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                    SizedBox(height: 8),
                    Text('Your pipeline is looking strong today.', style: TextStyle(color: context.colors.onSurfaceVariant)).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Swipeable Stat Cards
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSwipeableStatCard(
                      context,
                      title: 'Total Leads',
                      value: totalLeads,
                      subtitle: '+12% from last week',
                      icon: Icons.people_alt,
                      gradient: LinearGradient(colors: [context.colors.primary, Color(0xFF3A0CA3)]),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
                    _buildSwipeableStatCard(
                      context,
                      title: 'New Today',
                      value: todayLeads,
                      subtitle: 'Active prospects',
                      icon: Icons.bolt,
                      gradient: const LinearGradient(colors: [Color(0xFFF72585), Color(0xFF7209B7)]),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
                    _buildSwipeableStatCard(
                      context,
                      title: 'Interested',
                      value: interestedLeads,
                      subtitle: 'Hot leads',
                      icon: Icons.star_rounded,
                      gradient: const LinearGradient(colors: [Color(0xFF4CC9F0), Color(0xFF4361EE)]),
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
                    _buildSwipeableStatCard(
                      context,
                      title: 'Closed Deals',
                      value: closedLeads,
                      subtitle: 'Completed sales',
                      icon: Icons.handshake,
                      gradient: const LinearGradient(colors: [Color(0xFF2DC653), Color(0xFF136F2D)]),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Quick Actions
                    Text(
                      'QUICK ACTIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionBtn(
                            context,
                            icon: Icons.person_add_rounded,
                            label: 'Add Lead',
                            onTap: () => context.push('/leads/create'),
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionBtn(
                            context,
                            icon: Icons.view_kanban_rounded,
                            label: 'Pipeline',
                            onTap: () => context.go('/leads'),
                            isPrimary: false,
                          ),
                        ),
                      ],
                    ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 32),

                    // Recent Activity Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT ACTIVITY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/notifications'),
                          child: Text('See All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.colors.primary)),
                        ),
                      ],
                    ).animate().fadeIn(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Recent Activity List
            if (activityState.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: List.generate(3, (index) => _buildSkeletonActivity()),
                  ),
                ),
              )
            else if (activityState.activities.isEmpty)
               SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No recent activity.', style: TextStyle(color: context.colors.onSurfaceVariant))),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activity = activityState.activities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildActivityItem(context, activity)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 100 * index))
                            .slideY(begin: 0.1, end: 0),
                      );
                    },
                    childCount: activityState.activities.length,
                  ),
                ),
              ),
            
            // Bottom padding for nav bar overlap
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeableStatCard(
    BuildContext context, {
    required String title,
    required int value,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              // Animated Counter
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, required bool isPrimary}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? context.colors.primary : context.colors.surfaceHighlight,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: context.colors.outlineVariant),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : context.colors.onBackground, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : context.colors.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonActivity() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.surfaceHighlight,
              borderRadius: BorderRadius.circular(12),
            ),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: context.colors.outlineVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 120, color: context.colors.surfaceHighlight).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: context.colors.outlineVariant),
                SizedBox(height: 8),
                Container(height: 10, width: 80, color: context.colors.surfaceHighlight).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: context.colors.outlineVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityModel activity) {
    IconData icon = Icons.notifications;
    Color iconBgColor = context.colors.surfaceHighlight;
    Color iconColor = context.colors.primary;

    switch (activity.type) {
      case 'LEAD_CREATED':
        icon = Icons.person_add_rounded;
        iconBgColor = context.colors.primaryContainer;
        iconColor = context.colors.primary;
        break;
      case 'STAGE_CHANGED':
        icon = Icons.sync_rounded;
        iconBgColor = Color(0xFF3A2B00);
        iconColor = context.colors.warning;
        break;
      case 'TASK_COMPLETED':
        icon = Icons.task_alt_rounded;
        iconBgColor = Color(0xFF0D2D1B);
        iconColor = context.colors.success;
        break;
      case 'NOTE_ADDED':
        icon = Icons.description_rounded;
        iconBgColor = Color(0xFF1B143F);
        iconColor = context.colors.accent1;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onBackground),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.displayDescription,
                  style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            _getTimeAgo(activity.createdAt),
            style: TextStyle(fontSize: 10, color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w500),
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
