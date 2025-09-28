import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks({bool completed = false});
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> markAsCompleted(String id, bool completed);
  Future<Map<String, int>> getCompletedTasksStats();
}
