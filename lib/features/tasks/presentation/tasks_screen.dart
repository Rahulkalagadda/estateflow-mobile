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
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasksState.tasks.length,
              itemBuilder: (context, index) {
                final task = tasksState.tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: task.isCompleted ? AppColors.surfaceContainerLow : Colors.white,
                  child: ListTile(
                    title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                    subtitle: Text(task.description ?? ''),
                    trailing: task.isCompleted 
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : IconButton(
                          icon: const Icon(Icons.circle_outlined),
                          onPressed: () => ref.read(tasksProvider.notifier).toggleTask(task.id, task.isCompleted),
                        ),
                  ),
                );
              },
            ),
    );
  }
}
