import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/error_handler.dart';
import '../viewmodels/task_viewmodel.dart';
import '../widgets/task_list_item.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () => context.go('/completed-tasks'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.go('/stats'),
          ),
        ],
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            showErrorSnackBar(context, vm.errorMessage!);
            return Center(child: Text(vm.errorMessage!));
          }
          if (vm.tasks.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }
          return ListView.builder(
            itemCount: vm.tasks.length,
            itemBuilder: (context, index) {
              final task = vm.tasks[index];
              return TaskListItem(
                task: task,
                onMarkCompleted: (completed) =>
                    vm.markAsCompleted(task.id, completed),
                onEdit: () => context.go('/edit-task/${task.id}'),
                onDelete: () => vm.deleteTask(task.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-task'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
