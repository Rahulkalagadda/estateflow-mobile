import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    final stageColor = lead.stage?.uiColor ?? context.colors.primary;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: context.colors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${lead.firstName} ${lead.lastName}',
                style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onBackground, fontSize: 18),
              ),
              titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined), 
                onPressed: () {
                  context.push('/leads/${lead.id}/edit', extra: lead);
                },
              ),
              if (ref.watch(authProvider).user?.role != 'EMPLOYEE')
                IconButton(
                  icon: const Icon(Icons.person_add_alt),
                  onPressed: () => _showAssignmentDialog(context, ref, lead.id),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: context.colors.outlineVariant),
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
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: stageColor.withValues(alpha: 0.15),
                                    child: Text(
                                      lead.firstName.isNotEmpty ? lead.firstName[0].toUpperCase() : '?',
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: stageColor),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: stageColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: context.colors.surface, width: 3),
                                      ),
                                      child: const Icon(Icons.sync_alt, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: stageColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: stageColor.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      (lead.stage?.name ?? 'NEW').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: stageColor,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.email_outlined, size: 14, color: context.colors.onSurfaceVariant),
                                      SizedBox(width: 8),
                                      Expanded(child: Text(lead.email ?? 'No email', style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.phone_outlined, size: 14, color: context.colors.onSurfaceVariant),
                                      SizedBox(width: 8),
                                      Text(lead.phone ?? 'No phone', style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                ),
                
                // Pipeline Stats (Score)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.colors.accent1, context.colors.accent2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('LEAD SCORE', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('85', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                const Text(' / 100', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.local_fire_department, color: Colors.white),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ),
                const SizedBox(height: 24),

                // Collapsible Sections
                _buildCollapsibleSection(
                  context,
                  title: 'Overview',
                  icon: Icons.dashboard_outlined,
                  initiallyExpanded: true,
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDetailItem(context, 'LOCATION', lead.location ?? 'Not set', Icons.location_on),
                      _buildDetailItem(context, 'SOURCE', lead.source ?? 'Not set', Icons.campaign),
                      _buildDetailItem(context, 'BUDGET', lead.budget != null ? '₹${NumberFormat('#,##,###').format(lead.budget)}' : 'Not set', Icons.payments),
                      _buildDetailItem(context, 'PROPERTY', lead.interestedProperty ?? 'Not set', Icons.home_work),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                _buildCollapsibleSection(
                  context,
                  title: 'Activities',
                  icon: Icons.history,
                  child: _buildTimeline(context, ref, leadId),
                ).animate().fadeIn(delay: 300.ms),

                _buildCollapsibleSection(
                  context,
                  title: 'Notes',
                  icon: Icons.sticky_note_2_outlined,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: context.colors.surfaceHighlight, borderRadius: BorderRadius.circular(12)),
                    child: Text(lead.notes ?? 'No additional notes', style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13)),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: 0.9),
          border: Border(top: BorderSide(color: context.colors.outlineVariant)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStickyActionButton(context, Icons.call, 'Call', () {}),
            _buildStickyActionButton(context, Icons.email_outlined, 'Email', () {}),
            _buildStickyActionButton(context, Icons.sticky_note_2_outlined, 'Note', () => _showNoteDialog(context, ref, lead.id)),
            _buildStickyActionButton(context, Icons.event_outlined, 'Task', () => _showScheduleDialog(context, ref, lead.id)),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.colors.primary, size: 20),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection(BuildContext context, {required String title, required IconData icon, required Widget child, bool initiallyExpanded = false}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        iconColor: context.colors.primary,
        collapsedIconColor: context.colors.onSurfaceVariant,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: context.colors.primaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: context.colors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, WidgetRef ref, String leadId) {
    return Consumer(
      builder: (context, ref, child) {
        final activityState = ref.watch(activitiesProvider(leadId));
        
        if (activityState.isLoading) {
          return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()));
        }

        if (activityState.activities.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No activity recorded', style: TextStyle(color: context.colors.onSurfaceVariant, fontStyle: FontStyle.italic)),
            ),
          );
        }

        return Column(
          children: activityState.activities.map((act) {
            IconData icon = Icons.history;
            Color color = context.colors.primary;

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
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurface)),
                      Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(desc, style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: context.colors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: context.colors.onSurfaceVariant,
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
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Assign Lead to Agent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Select a team member to handle this lead', style: TextStyle(color: context.colors.onSurfaceVariant)),
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
                          backgroundColor: context.colors.primaryContainer.withValues(alpha: 0.2),
                          child: Text(member.firstName[0].toUpperCase(), style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text('${member.firstName} ${member.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(member.role),
                        trailing: Icon(Icons.chevron_right),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: context.colors.outlineVariant.withValues(alpha: 0.3))),
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
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Update Pipeline Stage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Moving the lead forward in the pipeline', style: TextStyle(color: context.colors.onSurfaceVariant)),
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
                        title: Text(stage.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? context.colors.primary : context.colors.onSurface)),
                        trailing: isSelected ? Icon(Icons.check_circle, color: context.colors.primary) : Icon(Icons.chevron_right, size: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), 
                          side: BorderSide(color: isSelected ? context.colors.primary.withValues(alpha: 0.5) : context.colors.outlineVariant.withValues(alpha: 0.3), width: isSelected ? 2 : 1)
                        ),
                        selected: isSelected,
                        selectedTileColor: context.colors.primaryContainer.withValues(alpha: 0.05),
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
              backgroundColor: context.colors.primary,
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
                      if (!context.mounted) return;
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
                backgroundColor: context.colors.primary,
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
