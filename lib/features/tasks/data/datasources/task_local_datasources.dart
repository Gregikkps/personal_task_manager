import 'package:logger/logger.dart';
import '../../../../core/services/database_service.dart';
import '../../domain/entities/task_entity.dart';

class TaskLocalDataSource {
  final DatabaseService _dbService;
  final Logger _logger = Logger();

  TaskLocalDataSource(this._dbService);

  Future<List<TaskEntity>> getAllTasks({bool completed = false}) async {
    try {
      final db = _dbService.database;
      final result = await db.query(
        'tasks',
        where: 'is_completed = ?',
        whereArgs: [completed ? 1 : 0],
        orderBy: 'deadline ASC',
      );
      return result.map(TaskEntity.fromMap).toList();
    } catch (e) {
      _logger.e('Get tasks error: $e');
      rethrow;
    }
  }

  Future<void> addTask(TaskEntity task) async {
    try {
      final db = _dbService.database;
      await db.insert('tasks', task.toMap());
    } catch (e) {
      _logger.e('Add task error: $e');
      rethrow;
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    try {
      final db = _dbService.database;
      await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      _logger.e('Update task error: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final db = _dbService.database;
      await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      _logger.e('Delete task error: $e');
      rethrow;
    }
  }

  Future<void> markAsCompleted(String id, bool completed) async {
    try {
      final db = _dbService.database;
      await db.update(
        'tasks',
        {
          'is_completed': completed ? 1 : 0,
          'completed_at': completed
              ? DateTime.now().millisecondsSinceEpoch
              : null,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.e('Mark completed error: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getCompletedTasksStats() async {
    try {
      final db = _dbService.database;
      final result = await db.rawQuery('''
        SELECT strftime('%w', datetime(completed_at / 1000, 'unixepoch')) as day, COUNT(*) as count
        FROM tasks WHERE is_completed = 1 AND completed_at IS NOT NULL
        GROUP BY day
      ''');
      final Map<String, int> stats = {};
      for (var row in result) {
        final day = _dayOfWeekFromInt(int.parse(row['day'] as String));
        stats[day] = row['count'] as int;
      }
      return stats;
    } catch (e) {
      _logger.e('Stats error: $e');
      return {};
    }
  }

  String _dayOfWeekFromInt(int day) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[day];
  }
}
