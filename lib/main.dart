import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/injector.dart';
import 'features/tasks/presentation/viewmodels/task_viewmodel.dart';
import 'features/statistics/presentation/viewmodels/stats_viewmodel.dart';
import 'navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TaskViewModel()),
            ChangeNotifierProvider(create: (_) => StatsViewModel()),
          ],
          child: MaterialApp.router(
            title: 'Task Manager',
            theme: AppTheme.darkTheme,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
