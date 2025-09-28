import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart'; // Załóżmy custom AppException

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repo = sl<TaskRepository>();
  final NotificationService _notificationService = sl<NotificationService>();

  List<TaskEntity> _tasks = [];
  List<TaskEntity> _completedTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskEntity> get tasks => _tasks;
  List<TaskEntity> get completedTasks => _completedTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _tasks = await _repo.getAllTasks();
      _completedTasks = await _repo.getAllTasks(completed: true);
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
      await _notificationService.scheduleNotification(id, title, deadline);
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    try {
      await _repo.updateTask(task);
      if (task.isCompleted) {
        await _notificationService.cancelNotification(task.id);
      } else {
        await _notificationService.scheduleNotification(
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
      await _notificationService.cancelNotification(id);
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsCompleted(String id, bool completed) async {
    try {
      await _repo.markAsCompleted(id, completed);
      if (completed) {
        await _notificationService.cancelNotification(id);
      }
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }
}
