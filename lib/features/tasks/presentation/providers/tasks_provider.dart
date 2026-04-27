import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/task_model.dart';
import '../../../../services/tasks_service.dart';

class TasksState {
  final bool isLoading;
  final List<TaskModel> tasks;
  final String? error;

  TasksState({
    this.isLoading = false,
    this.tasks = const [],
    this.error,
  });

  TasksState copyWith({
    bool? isLoading,
    List<TaskModel>? tasks,
    String? error,
  }) {
    return TasksState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      error: error,
    );
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final tasksService = ref.watch(tasksServiceProvider);
  return TasksNotifier(tasksService);
});

class TasksNotifier extends StateNotifier<TasksState> {
  final TasksService _tasksService;

  TasksNotifier(this._tasksService) : super(TasksState()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _tasksService.fetchTasks();
      state = state.copyWith(isLoading: false, tasks: tasks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleTask(String taskId, bool currentStatus) async {
    try {
      final updatedTask = await _tasksService.updateTaskStatus(taskId, !currentStatus);
      final updatedTasks = state.tasks.map((task) {
        return task.id == taskId ? updatedTask : task;
      }).toList();
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
