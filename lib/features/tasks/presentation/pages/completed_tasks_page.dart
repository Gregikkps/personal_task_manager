import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../widgets/task_list_item.dart';

class CompletedTasksPage extends StatefulWidget {
  const CompletedTasksPage({super.key});

  @override
  State<CompletedTasksPage> createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
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
      appBar: AppBar(title: const Text('Completed Tasks')),
      body: Consumer<TaskViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.completedTasks.isEmpty) {
            return const Center(child: Text('No completed tasks'));
          }
          return ListView.builder(
            itemCount: vm.completedTasks.length,
            itemBuilder: (context, index) {
              final task = vm.completedTasks[index];
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
    );
  }
}
