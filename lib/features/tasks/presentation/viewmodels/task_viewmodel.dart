import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repo = sl<TaskRepository>();
  final NotificationService _notificationService = sl<NotificationService>();

  List<TaskEntity> _tasks = [];
  List<TaskEntity> _completedTasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  List<TaskEntity> get tasks => _tasks;
  List<TaskEntity> get completedTasks => _completedTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    await loadTasks();
    _initialized = true;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getAllTasks(),
        _repo.getAllTasks(completed: true),
      ]);

      _tasks = results[0];
      _completedTasks = results[1];
    } catch (e) {
      _errorMessage = e is AppException ? e.message : 'Unexpected error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(
    String title,
    String? description,
    DateTime deadline,
  ) async {
    final id = const Uuid().v4();
    final task = TaskEntity(
      id: id,
      title: title,
      description: description,
      deadline: deadline,
    );
    try {
      await _repo.addTask(task);
      _notificationService.scheduleNotification(id, title, deadline);
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    try {
      await _repo.updateTask(task);
      if (task.isCompleted) {
        _notificationService.cancelNotification(task.id);
      } else {
        _notificationService.scheduleNotification(
          task.id,
          task.title,
          task.deadline,
        );
      }
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repo.deleteTask(id);
      _notificationService.cancelNotification(id);
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsCompleted(String id, bool completed) async {
    try {
      await _repo.markAsCompleted(id, completed);
      if (completed) {
        _notificationService.cancelNotification(id);
      }
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }
}
