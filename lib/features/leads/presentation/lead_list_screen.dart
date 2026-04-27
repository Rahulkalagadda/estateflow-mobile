import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/lead_model.dart';
import 'providers/leads_provider.dart';

class LeadListScreen extends ConsumerWidget {
  const LeadListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsState = ref.watch(leadsProvider);
    final leads = leadsState.leads;
    
    // Calculate stats
    final totalValue = leads.fold(0.0, (sum, l) => sum + (double.tryParse(l.notes?.match(RegExp(r'\$(\d+(\.\d+)?)'))?.group(1) ?? '0') ?? 0.0));
    final valueStr = totalValue >= 1000000 ? '\$${(totalValue / 1000000).toStringAsFixed(1)}M' : '\$${(totalValue / 1000).toStringAsFixed(0)}K';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => context.push('/notifications')),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=current_user'),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search leads...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                // Pipeline Stats Bento
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ACTIVE LEADS', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Text('${leads.length}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixedDim,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PIPELINE VALUE', style: TextStyle(fontSize: 10, color: AppColors.onTertiaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Text(valueStr, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.onTertiaryFixed, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Inquiries', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 16),

                // Lead Cards from Riverpod state
                leadsState.isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 80.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : leads.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 80.0),
                            child: Column(
                              children: [
                                Icon(Icons.person_search_outlined, size: 80, color: AppColors.onSurfaceVariant.withOpacity(0.2)),
                                const SizedBox(height: 16),
                                Text('No leads found', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                Text('Start by adding your first lead to the pipeline.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => ref.read(leadsProvider.notifier).fetchLeads(),
                                  child: const Text('Refresh Pipeline'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: leads.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildLeadCard(
                                  context,
                                  ref: ref,
                                  lead: leads[index],
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/leads/create'),
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLeadCard(
    BuildContext context, {
    required WidgetRef ref,
    required LeadModel lead,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(leadsProvider.notifier).selectLead(lead.id);
        context.push('/leads/${lead.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryContainer.withOpacity(0.1),
                  child: Text(lead.firstName.isNotEmpty ? lead.firstName[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${lead.firstName} ${lead.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(lead.email ?? 'No email', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lead.stageId.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notes, size: 20, color: AppColors.primaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lead.notes ?? 'No additional notes',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}
