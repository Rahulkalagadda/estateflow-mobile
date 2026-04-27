import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/models/task_model.dart';

final tasksServiceProvider = Provider<TasksService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TasksService(apiClient);
});

class TasksService {
  final ApiClient _apiClient;

  TasksService(this._apiClient);

  Future<List<TaskModel>> fetchTasks() async {
    try {
      final response = await _apiClient.dio.get('/tasks');
      return (response.data['data'] as List).map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<TaskModel> updateTaskStatus(String taskId, bool isCompleted) async {
    try {
      final response = await _apiClient.dio.patch('/tasks/$taskId', data: {'isCompleted': isCompleted});
      return TaskModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
