import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/task_entity.dart';
import '../viewmodels/task_viewmodel.dart';
import '../../../../core/utils/validators.dart';

class AddEditTaskPage extends StatefulWidget {
  final String? taskId;

  const AddEditTaskPage({super.key, this.taskId});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  TaskEntity? _existingTask;
  final Logger _logger = Logger();
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    if (widget.taskId != null) {
      _loadExistingTask();
    }
    _titleController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);
  }

  void _loadExistingTask() {
    final vm = context.read<TaskViewModel>();
    _existingTask = vm.tasks.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => vm.completedTasks.firstWhere(
        (t) => t.id == widget.taskId,
        orElse: () => throw Exception('Task not found'),
      ),
    );
    _titleController.text = _existingTask!.title;
    _descriptionController.text = _existingTask!.description ?? '';
    _deadline = _existingTask!.deadline;
  }

  void _onChanged() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      final vm = context.read<TaskViewModel>();
      try {
        final task =
            _existingTask?.copyWith(
              title: _titleController.text,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              deadline: _deadline,
            ) ??
            TaskEntity(
              id: DateTime.now().toIso8601String(),
              title: _titleController.text,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              deadline: _deadline,
              isCompleted: false,
            );
        if (_existingTask != null) {
          await vm.updateTask(task);
        } else {
          await vm.addTask(task.title, task.description, task.deadline);
        }
        if (mounted) context.pop();
      } catch (e) {
        _logger.e('Error saving task', error: e);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save task: $e')));
        }
      }
    }
  }

  Future<void> _onPopInvoked(bool didPop) async {
    if (didPop) return;
    if (_isDirty) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to discard your changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (shouldPop ?? false) if (mounted) context.pop();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onPopInvoked;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.taskId == null ? 'Add Task' : 'Edit Task'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onPopInvoked(false),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  validator: validateNotEmpty,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(_deadline)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      builder: (context, child) => Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(colorScheme: Theme.of(context).colorScheme),
                        child: child!,
                      ),
                    );
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_deadline),
                      );
                      if (time != null) {
                        setState(
                          () => _deadline = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ),
                        );
                      }
                    }
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_onChanged);
    _descriptionController.removeListener(_onChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
