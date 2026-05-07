import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/tasks_provider.dart';
import '../../../core/theme/app_theme.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksProvider);

    return Scaffold(
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
                      Icon(Icons.calendar_today_outlined, size: 80, color: AppColors.onSurfaceVariant.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('No tasks scheduled', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      const Text('Tasks you create will appear here.', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
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
                        color: task.isCompleted ? AppColors.surfaceContainerLow : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              color: task.isCompleted ? AppColors.primary : AppColors.outline,
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
                                    color: task.isCompleted ? AppColors.outline : AppColors.onSurface,
                                  ),
                                ),
                                if (task.description != null && task.description!.isNotEmpty)
                                  Text(
                                    task.description!,
                                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
