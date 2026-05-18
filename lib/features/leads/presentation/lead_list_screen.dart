import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/lead_model.dart';
import 'providers/leads_provider.dart';
import 'providers/pipeline_provider.dart';

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isBoardView = false;
  bool _isDragging = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(leadsProvider);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final leadsState = ref.watch(leadsProvider);
    final leads = leadsState.leads;
    
    // Simple local search
    final filteredLeads = leads.where((l) {
      final query = _searchController.text.toLowerCase();
      final name = '${l.firstName} ${l.lastName}'.toLowerCase();
      return name.contains(query) || (l.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (_isBoardView) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: const Text('Leads Board', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: context.colors.background,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.view_list_rounded, color: context.colors.primary),
              onPressed: () {
                setState(() {
                  _isBoardView = false;
                });
              },
            ),
            const SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search leads...',
                  prefixIcon: Icon(Icons.search, color: context.colors.onSurfaceVariant),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: context.colors.onSurfaceVariant),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : Icon(Icons.tune, color: context.colors.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ),
        body: _buildBoardView(context, filteredLeads, ref),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: NestedScrollView(
        // NestedScrollView keeps the SliverAppBar behaviour (collapsing/floating)
        // while its body uses a plain ListView.builder which does NOT participate
        // in the horizontal gesture arena — Dismissible gets horizontal drags cleanly.
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            forceElevated: innerBoxIsScrolled,
            backgroundColor: context.colors.background.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 24,
            title: const Text('Leads', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(Icons.view_kanban_rounded, color: context.colors.primary),
                onPressed: () {
                  setState(() {
                    _isBoardView = true;
                  });
                },
              ).animate().scale(delay: 200.ms),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search leads...',
                    prefixIcon: Icon(Icons.search, color: context.colors.onSurfaceVariant),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: context.colors.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : Icon(Icons.tune, color: context.colors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: context.colors.primary,
          backgroundColor: context.colors.surface,
          child: Builder(
            builder: (context) {
              if (leadsState.isLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: 5,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSkeletonCard(),
                  ),
                );
              }

              if (filteredLeads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_rounded, size: 80,
                          color: context.colors.onSurfaceVariant.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text('No leads found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: context.colors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text('Try adjusting your search.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant)),
                    ],
                  ).animate().fadeIn(),
                );
              }

              // Plain ListView.builder — does NOT enter the horizontal gesture arena.
              // Dismissible gets exclusive ownership of horizontal drags.
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 116),
                itemCount: filteredLeads.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildLeadCard(context, ref: ref, lead: filteredLeads[index], enableSwipe: true)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 50 * index))
                        .slideY(begin: 0.1, end: 0),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBoardView(BuildContext context, List<LeadModel> filteredLeads, WidgetRef ref) {
    final pipelineState = ref.watch(pipelineProvider);
    if (pipelineState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: _isDragging ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pipelineState.stages.length,
        itemBuilder: (context, index) {
          final stage = pipelineState.stages[index];
          final stageLeads = filteredLeads.where((l) => l.stageId == stage.id).toList();
          
          return Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: context.colors.surfaceHighlight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.colors.outlineVariant),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: stage.uiColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: Container(width: 12, height: 12, decoration: BoxDecoration(color: stage.uiColor, shape: BoxShape.circle)),
                      ),
                      const SizedBox(width: 12),
                      Text(stage.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.colors.outlineVariant)),
                        child: Text('${stageLeads.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DragTarget<LeadModel>(
                    onWillAcceptWithDetails: (details) => details.data.stageId != stage.id,
                    onAcceptWithDetails: (details) async {
                      final success = await ref.read(leadsProvider.notifier).updateLeadStage(details.data.id, stage.id);
                      if (!success && context.mounted) {
                        final error = ref.read(leadsProvider).error;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error ?? 'Failed to update lead stage'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty ? stage.uiColor.withValues(alpha: 0.05) : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: stageLeads.length,
                          itemBuilder: (context, leadIndex) {
                            final lead = stageLeads[leadIndex];
                            return Draggable<LeadModel>(
                              data: lead,
                              onDragStarted: () {
                                setState(() {
                                  _isDragging = true;
                                });
                              },
                              onDragEnd: (_) {
                                setState(() {
                                  _isDragging = false;
                                });
                              },
                              onDraggableCanceled: (_, __) {
                                setState(() {
                                  _isDragging = false;
                                });
                              },
                              onDragCompleted: () {
                                setState(() {
                                  _isDragging = false;
                                });
                              },
                              feedback: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.85 - 32,
                                  child: Opacity(
                                    opacity: 0.9,
                                    child: _buildLeadCard(context, ref: ref, lead: lead, enableSwipe: false),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _buildLeadCard(context, ref: ref, lead: lead, enableSwipe: false),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildLeadCard(context, ref: ref, lead: lead, enableSwipe: false)
                                  .animate().fadeIn(delay: Duration(milliseconds: 50 * leadIndex)),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1, end: 0);
        },
      );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              color: context.colors.surfaceHighlight,
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: context.colors.outlineVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 150, color: context.colors.surfaceHighlight).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: context.colors.outlineVariant),
                SizedBox(height: 8),
                Container(height: 12, width: 100, color: context.colors.surfaceHighlight).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: context.colors.outlineVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(
    BuildContext context, {
    required WidgetRef ref,
    required LeadModel lead,
    bool enableSwipe = true,
  }) {
    final statusColor = lead.stage?.uiColor ?? context.colors.primary;
    final valueStr = lead.budget != null ? '₹${(lead.budget! / 100000).toStringAsFixed(1)}L' : 'No budget';

    final cardContent = GestureDetector(
      onTap: () {
        ref.read(leadsProvider.notifier).selectLead(lead.id);
        context.push('/leads/${lead.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  child: Text(
                    lead.firstName.isNotEmpty ? lead.firstName[0].toUpperCase() : '?', 
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${lead.firstName} ${lead.lastName}', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.colors.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        valueStr, 
                        style: TextStyle(fontSize: 13, color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (lead.stage?.name ?? 'NEW').toUpperCase(),
                    style: TextStyle(
                      fontSize: 9, 
                      fontWeight: FontWeight.w800, 
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: context.colors.outlineVariant, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last act: ${_getTimeAgo(lead.createdAt)}',
                  style: TextStyle(fontSize: 11, color: context.colors.onSurfaceVariant),
                ),
                Row(
                  children: [
                    _buildQuickActionBtn(Icons.phone_rounded, () {
                      // Call action
                    }),
                    const SizedBox(width: 12),
                    _buildQuickActionBtn(Icons.email_rounded, () {
                      // Email action
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (enableSwipe) {
      return Dismissible(
        key: Key(lead.id),
        direction: DismissDirection.horizontal, // Enable swipe left & swipe right
        dragStartBehavior: DragStartBehavior.down, // Capture the gesture instantly upon contact to beat vertical scroll hijack
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: context.colors.primary, // Swipe right for Quick Call action
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerLeft,
          child: const Icon(Icons.phone_rounded, color: Colors.white),
        ),
        secondaryBackground: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: context.colors.error, // Swipe left to archive
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          child: const Icon(Icons.archive_rounded, color: Colors.white),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            // Archive action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${lead.firstName} ${lead.lastName} archived'),
                backgroundColor: context.colors.surfaceHighlight,
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: context.colors.primary,
                  onPressed: () {},
                ),
              ),
            );
          } else {
            // Call action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Starting call with ${lead.firstName}...'),
                backgroundColor: context.colors.primary,
              ),
            );
          }
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildQuickActionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.surfaceHighlight,
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Icon(icon, size: 16, color: context.colors.onSurface),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
