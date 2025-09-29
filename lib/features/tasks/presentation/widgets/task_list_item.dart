import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';

class TaskListItem extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<bool> onMarkCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onMarkCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(
        '${task.description ?? ''}\nDeadline: ${DateFormat('yyyy-MM-dd HH:mm').format(task.deadline)}',
      ),
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (value) => onMarkCompleted(value ?? false),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
