import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../services/users_service.dart';
import 'providers/leads_provider.dart';
import 'providers/activities_provider.dart';
import 'package:intl/intl.dart';

class LeadDetailsScreen extends ConsumerWidget {
  final String leadId;

  const LeadDetailsScreen({super.key, required this.leadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadState = ref.watch(leadsProvider);
    final lead = leadState.selectedLead;

    if (lead == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Not Found')),
        body: const Center(child: Text('Could not load lead details')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Details', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                    width: 96,
                                    height: 96,
                                    color: AppColors.primaryFixed,
                                    child: Center(
                                      child: Text(lead.firstName.isNotEmpty ? lead.firstName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onPrimaryFixed)),
                                    ),
                                  ),
                            ),
                            Positioned(
                              bottom: -8,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  lead.stageId.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurfaceVariant
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${lead.firstName} ${lead.lastName}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(lead.email ?? 'No email', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone_iphone, size: 16, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text(lead.phone ?? 'No phone', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stage
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CURRENT STAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(lead.stageId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (ref.watch(authProvider).user?.role != 'EMPLOYEE')
                    ElevatedButton.icon(
                      onPressed: () {
                        // Show assignment dialog
                        _showAssignmentDialog(context, ref, lead.id);
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Assign'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  if (ref.watch(authProvider).user?.role != 'EMPLOYEE')
                    const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sticky_note_2),
                    label: const Text('Add Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.onSurface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.event),
                    label: const Text('Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.onSurface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            // Pipeline Stats
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LEAD SCORE', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('85', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              const Text(' / 100', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity Timeline', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final activityState = ref.watch(activitiesProvider(leadId));
                      
                      if (activityState.isLoading) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ));
                      }

                      if (activityState.activities.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text('No activity recorded', style: TextStyle(color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic)),
                          ),
                        );
                      }

                      return Column(
                        children: activityState.activities.map((act) {
                          IconData icon = Icons.history;
                          Color color = AppColors.primary;

                          if (act.type == 'LEAD_CREATED') {
                            icon = Icons.person_add;
                            color = Colors.emerald;
                          } else if (act.type == 'LEAD_ASSIGNED') {
                            icon = Icons.assignment_ind;
                            color = Colors.blue;
                          } else if (act.type == 'STAGE_CHANGED') {
                            icon = Icons.sync_alt;
                            color = Colors.orange;
                          }

                          return _buildTimelineItem(
                            context,
                            title: act.type.replaceAll('_', ' '),
                            time: _formatDateTime(act.createdAt),
                            desc: '${act.userFirstName} ${act.userLastName} performed this action',
                            icon: icon,
                            color: color,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String title,
    required String time,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 4),
            ),
            child: Icon(icon, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: color, width: 4)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(desc, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  void _showAssignmentDialog(BuildContext context, WidgetRef ref, String leadId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assign Lead to Agent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Select a team member to handle this lead', style: TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder(
                future: ref.read(usersServiceProvider).fetchTeamMembers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final members = snapshot.data ?? [];
                  return ListView.separated(
                    itemCount: members.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return ListTile(
                        onTap: () async {
                          await ref.read(leadsProvider.notifier).assignLead(leadId, member.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                          child: Text(member.firstName[0].toUpperCase()),
                        ),
                        title: Text('${member.firstName} ${member.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(member.role),
                        trailing: const Icon(Icons.chevron_right),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
