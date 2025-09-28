import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/task_entity.dart';
import '../viewmodels/task_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    if (widget.taskId != null) {
      _loadExistingTask();
    }
  }

  void _loadExistingTask() {
    final vm = context.read<TaskViewModel>();
    _existingTask = vm.tasks.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => vm.completedTasks.firstWhere((t) => t.id == widget.taskId),
    );
    _titleController.text = _existingTask!.title;
    _descriptionController.text = _existingTask!.description ?? '';
    _deadline = _existingTask!.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      final vm = context.read<TaskViewModel>();
      try {
        if (_existingTask != null) {
          final updatedTask = _existingTask!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text,
            deadline: _deadline,
          );
          await vm.updateTask(updatedTask);
        } else {
          await vm.addTask(
            _titleController.text,
            _descriptionController.text,
            _deadline,
          );
        }
        if (mounted) context.canPop();
      } catch (e) {
        _logger.e("Error log", error: e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: validateNotEmpty,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              ListTile(
                title: Text(
                  'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(_deadline)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_deadline),
                    );
                    if (time != null) {
                      setState(() {
                        _deadline = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              ElevatedButton(onPressed: _saveTask, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
