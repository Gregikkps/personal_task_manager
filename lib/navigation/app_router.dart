import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/tasks/presentation/pages/task_list_page.dart';
import '../features/tasks/presentation/pages/add_edit_task_page.dart';
import '../features/statistics/presentation/pages/stats_page.dart';
import '../features/tasks/presentation/pages/completed_tasks_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TaskListPage()),
    GoRoute(
      path: '/add-task',
      builder: (context, state) => const AddEditTaskPage(),
    ),
    GoRoute(
      path: '/edit-task/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddEditTaskPage(taskId: id);
      },
    ),
    GoRoute(
      path: '/completed-tasks',
      builder: (context, state) => const CompletedTasksPage(),
    ),
    GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found'))),
);
