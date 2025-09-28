import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasources.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<List<TaskEntity>> getAllTasks({bool completed = false}) =>
      _dataSource.getAllTasks(completed: completed);

  @override
  Future<void> addTask(TaskEntity task) => _dataSource.addTask(task);

  @override
  Future<void> updateTask(TaskEntity task) => _dataSource.updateTask(task);

  @override
  Future<void> deleteTask(String id) => _dataSource.deleteTask(id);

  @override
  Future<void> markAsCompleted(String id, bool completed) =>
      _dataSource.markAsCompleted(id, completed);

  @override
  Future<Map<String, int>> getCompletedTasksStats() =>
      _dataSource.getCompletedTasksStats();
}
