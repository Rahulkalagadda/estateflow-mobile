import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/tasks_provider.dart';
import '../../../core/theme/app_theme.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: tasksState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasksState.tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 80, color: context.colors.onSurfaceVariant.withValues(alpha: 0.2)),
                      SizedBox(height: 16),
                      Text('No tasks scheduled', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                      SizedBox(height: 8),
                      Text('Tasks you create will appear here.', style: TextStyle(color: context.colors.onSurfaceVariant)),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: tasksState.tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasksState.tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: task.isCompleted ? context.colors.surfaceHighlight.withValues(alpha: 0.5) : context.colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              color: task.isCompleted ? context.colors.primary : context.colors.outline,
                            ),
                            onPressed: () => ref.read(tasksProvider.notifier).toggleTask(task.id, task.isCompleted),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    color: task.isCompleted ? context.colors.outline : context.colors.onBackground,
                                  ),
                                ),
                                if (task.description != null && task.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      task.description!,
                                      style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1, end: 0);
                  },
                ),
    );
  }
}
