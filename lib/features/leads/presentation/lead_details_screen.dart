import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../services/users_service.dart';
import 'providers/leads_provider.dart';
import 'providers/activities_provider.dart';
import 'providers/pipeline_provider.dart';
import '../../tasks/presentation/providers/tasks_provider.dart';
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
                        GestureDetector(
                          onTap: () => _showStageSelectionSheet(context, ref, lead.id, lead.stageId),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                      width: 96,
                                      height: 96,
                                      color: (lead.stage?.uiColor ?? AppColors.primaryFixed).withValues(alpha: 0.2),
                                      child: Center(
                                        child: Text(
                                          lead.firstName.isNotEmpty ? lead.firstName[0].toUpperCase() : '?', 
                                          style: TextStyle(
                                            fontSize: 32, 
                                            fontWeight: FontWeight.bold, 
                                            color: lead.stage?.uiColor ?? AppColors.primary
                                          )
                                        ),
                                      ),
                                    ),
                              ),
                              Positioned(
                                bottom: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: lead.stage?.uiColor ?? AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${lead.firstName} ${lead.lastName}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (lead.stage?.uiColor ?? AppColors.surfaceContainerHigh).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: (lead.stage?.uiColor ?? AppColors.outlineVariant).withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  (lead.stage?.name ?? 'NEW').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: lead.stage?.uiColor ?? AppColors.onSurfaceVariant,
                                    letterSpacing: 1
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(lead.email ?? 'No email', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text(lead.phone ?? 'No phone', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Additional Details Grid
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildDetailItem('LOCATION', lead.location ?? 'Not set', Icons.location_on),
                        _buildDetailItem('SOURCE', lead.source ?? 'Not set', Icons.campaign),
                        _buildDetailItem('BUDGET', lead.budget != null ? '₹${NumberFormat('#,##,###').format(lead.budget)}' : 'Not set', Icons.payments),
                        _buildDetailItem('PROPERTY', lead.interestedProperty ?? 'Not set', Icons.home_work),
                        _buildDetailItem('PRE-APPROVAL', lead.preapprovalStatus ?? 'Not set', Icons.verified_user),
                      ],
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
                    onPressed: () => _showNoteDialog(context, ref, lead.id),
                    icon: const Icon(Icons.sticky_note_2_outlined),
                    label: const Text('Add Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showScheduleDialog(context, ref, lead.id),
                    icon: const Icon(Icons.event_outlined),
                    label: const Text('Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
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
                            color = Colors.teal;
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

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                          child: Text(member.firstName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text('${member.firstName} ${member.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(member.role),
                        trailing: const Icon(Icons.chevron_right),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
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

  void _showStageSelectionSheet(BuildContext context, WidgetRef ref, String leadId, String currentStageId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Update Pipeline Stage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Moving the lead forward in the pipeline', style: TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final pipelineState = ref.watch(pipelineProvider);
                  if (pipelineState.isLoading) return const Center(child: CircularProgressIndicator());
                  
                  return ListView.separated(
                    itemCount: pipelineState.stages.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final stage = pipelineState.stages[index];
                      final isSelected = stage.id == currentStageId;
                      
                      return ListTile(
                        onTap: () async {
                          await ref.read(leadsProvider.notifier).updateLeadStage(leadId, stage.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: stage.uiColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(stage.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : AppColors.onSurface)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : const Icon(Icons.chevron_right, size: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), 
                          side: BorderSide(color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant.withValues(alpha: 0.3), width: isSelected ? 2 : 1)
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.primaryContainer.withValues(alpha: 0.05),
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

  void _showNoteDialog(BuildContext context, WidgetRef ref, String leadId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Internal Note', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter your update or observation...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(activitiesProvider(leadId).notifier).addNote(leadId, controller.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, WidgetRef ref, String leadId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Schedule Task', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g., Follow up call',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date & Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('MMM d, yyyy - h:mm a').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await ref.read(tasksProvider.notifier).createTask({
                    'leadId': leadId,
                    'title': titleController.text,
                    'description': descController.text,
                    'dueDate': selectedDate.toIso8601String(),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
