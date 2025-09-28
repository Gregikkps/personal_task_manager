import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../tasks/domain/repositories/task_repository.dart';

class StatsViewModel extends ChangeNotifier {
  final TaskRepository _repo = sl<TaskRepository>();

  int _totalCompleted = 0;
  String _mostProductiveDay = 'None';
  bool _isLoading = false;
  String? _errorMessage;

  int get totalCompleted => _totalCompleted;
  String get mostProductiveDay => _mostProductiveDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final stats = await _repo.getCompletedTasksStats();
      _totalCompleted = stats.values.fold(0, (sum, count) => sum + count);
      if (stats.isNotEmpty) {
        _mostProductiveDay = stats.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }
    } catch (e) {
      _errorMessage = 'Error loading stats';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
