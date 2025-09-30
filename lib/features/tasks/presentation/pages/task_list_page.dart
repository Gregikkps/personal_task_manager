import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_task_manager/features/weather/presentation/viewmodels/weather_viewmodel.dart';
import 'package:personal_task_manager/features/weather/presentation/widgets/weather_widget.dart';
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

class _TaskListPageState extends State<TaskListPage>
    with WidgetsBindingObserver {
  bool _hasLoadedWeather = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TaskViewModel>().loadTasks();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<WeatherViewModel>().loadWeather();
          _hasLoadedWeather = true;
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _hasLoadedWeather) {
      if (mounted) {
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            final weatherVm = context.read<WeatherViewModel>();
            if (weatherVm.needsPermission || weatherVm.weather == null) {
              weatherVm.loadWeather();
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () => context.push('/completed-tasks'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/stats'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: const WeatherWidget(),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Consumer<TaskViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.errorMessage != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      showErrorSnackBar(context, vm.errorMessage!);
                    }
                  });
                  return Center(child: Text(vm.errorMessage!));
                }
                if (vm.tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet'));
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: vm.tasks.length,
                  itemBuilder: (context, index) {
                    final task = vm.tasks[index];
                    return TaskListItem(
                      task: task,
                      onMarkCompleted: (completed) =>
                          vm.markAsCompleted(task.id, completed),
                      onEdit: () => context.push('/edit-task/${task.id}'),
                      onDelete: () => vm.deleteTask(task.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-task'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
